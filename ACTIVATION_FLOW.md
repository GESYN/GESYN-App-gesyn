# Fluxo de Ativação de Dispositivos - GESYN

## ⚠️ IMPORTANTE

**Ativar um dispositivo não é apenas clicar em "Ativar"!**

O processo de ativação envolve um fluxo completo de configuração via Bluetooth:

## 📋 Fluxo Completo de Ativação

### Passo 1: Cadastro do Dispositivo

- Usuário cria o dispositivo no app
- Sistema gera `deviceId` e `apiToken` únicos
- Dispositivo fica com status `OFFLINE` e `INACTIVE`

### Passo 2: Solicitar Credenciais WiFi

- Quando usuário clica em "Ativar"
- App abre dialog pedindo:
  - **SSID** (nome da rede WiFi)
  - **Senha WiFi**

### Passo 3: Comunicação Bluetooth

**App envia ao ESP32 via Bluetooth:**

```json
{
  "ssid": "MinhaRedeWiFi",
  "password": "senha123",
  "apiToken": "dev_abc123...",
  "deviceId": "GESYN_SOLUM-123456",
  "serverUrl": "http://3.22.64.117:3100"
}
```

### Passo 4: ESP32 Processa

- Recebe dados via Bluetooth
- Salva na memória não-volátil
- Tenta conectar ao WiFi
- Aguarda obter IP

### Passo 5: ESP32 Responde

**ESP32 envia resposta via Bluetooth:**

✅ **Sucesso:**

```json
{
  "status": "connected",
  "wifiConnected": true,
  "ip": "192.168.1.100",
  "message": "Dispositivo configurado com sucesso"
}
```

❌ **Falha:**

```json
{
  "status": "error",
  "wifiConnected": false,
  "error": "Senha incorreta",
  "message": "Falha ao conectar à rede WiFi"
}
```

### Passo 6: App Atualiza Servidor

**Se ESP32 conectou com sucesso:**

```http
PATCH /api/v1/devices/{id}
Authorization: Bearer {userToken}

{
  "status": "ONLINE",
  "description": "Dispositivo ativado e conectado"
}
```

### Passo 7: Dispositivo Operacional

- ESP32 agora está conectado à internet
- Começa a enviar dados automaticamente ao servidor
- Usa o `apiToken` recebido para autenticação

---

## 🔐 Por que enviar o API Token via Bluetooth?

O **API Token** é essencial porque:

1. **Autenticação**: O ESP32 precisa se autenticar ao enviar dados
2. **Segurança**: Cada dispositivo tem seu próprio token único
3. **Rastreabilidade**: Servidor identifica qual dispositivo enviou os dados

### Exemplo de uso do Token pelo ESP32:

```cpp
// ESP32 envia dados ao servidor
http.addHeader("Authorization", "Bearer " + apiToken);

POST /api/v1/devices/GESYN_SOLUM-123456/data
{
  "temperature": 25.5,
  "humidity": 60.2,
  "timestamp": "2026-02-10T10:30:00Z"
}
```

---

## 📱 Interface do App

### Tela de Dispositivos

1. Lista todos os dispositivos do usuário
2. Mostra status: ONLINE/OFFLINE
3. Mostra config status: ATIVO/INATIVO
4. Botão **"Ativar"** disponível para dispositivos inativos

### Quando usuário clica em "Ativar"

1. ⚡ Dialog: "Configurar WiFi"
   - Input: SSID
   - Input: Senha
   - Botões: Cancelar | Conectar

2. ⏳ Loading: "Conectando ao dispositivo via Bluetooth..."
   - Enviando dados ao ESP32

3. ⏳ Loading: "ESP32 conectando à rede WiFi..."
   - Aguardando confirmação do ESP32

4. ✅ Sucesso: "Dispositivo Ativado!"
   - Mostra IP obtido
   - Informa que dispositivo está operacional

5. ❌ Erro: "Falha na conexão WiFi"
   - Mostra mensagem de erro
   - Usuário pode tentar novamente

---

## 🛠️ Implementação Técnica

### Arquivos Modificados

#### `lib/services/bluetooth_service.dart`

```dart
// Método principal para enviar config ao ESP32
static Future<Map<String, dynamic>> sendConfigToESP32({
  required String ssid,
  required String password,
  required String apiToken,
  required String deviceId,
})
```

#### `lib/screens/devices_screen.dart`

```dart
// Método completo de ativação
Future<void> _activateDevice(Device device) {
  1. Solicita credenciais WiFi
  2. Envia via Bluetooth ao ESP32
  3. Aguarda confirmação
  4. Atualiza status no servidor
  5. Mostra resultado ao usuário
}
```

#### `lib/services/device_service.dart`

```dart
// Atualiza dispositivo no servidor
static Future<Map<String, dynamic>> updateDevice({
  required String id,
  String? status,
  String? token,
})
```

---

## 🧪 Testando (Modo Mock)

Atualmente o Bluetooth está **mockado** (simulado). O fluxo funciona assim:

1. ✅ App solicita credenciais WiFi
2. ✅ Simula envio via Bluetooth (2 segundos)
3. ✅ Simula resposta do ESP32 (3 segundos)
4. ✅ Atualiza status no servidor (real)
5. ✅ Mostra sucesso ao usuário

### Para implementar Bluetooth real:

1. Adicionar biblioteca: `flutter_blue_plus`
2. Escanear dispositivos próximos
3. Conectar ao ESP32 específico
4. Escrever na característica BLE de configuração
5. Ler resposta da característica BLE de status

Ver: `BLUETOOTH_PROTOCOL.md` para detalhes técnicos

---

## 📊 Estados do Dispositivo

### Status (Conectividade)

- **OFFLINE**: Dispositivo não está conectado
- **ONLINE**: Dispositivo conectado e operacional

### Config Status (Configuração)

- **INACTIVE**: Ainda não foi ativado/configurado
- **ACTIVE**: Configurado e pronto para uso

### Combinações Possíveis

| Status  | Config Status | Significado                                      |
| ------- | ------------- | ------------------------------------------------ |
| OFFLINE | INACTIVE      | Dispositivo cadastrado mas nunca ativado         |
| OFFLINE | ACTIVE        | Dispositivo já foi ativado mas está desconectado |
| ONLINE  | ACTIVE        | Dispositivo funcionando normalmente ✅           |
| ONLINE  | INACTIVE      | Estado inválido (não deve ocorrer)               |

---

## 🎯 Próximos Passos

- [ ] Implementar Bluetooth real (flutter_blue_plus)
- [ ] Adicionar scanning de dispositivos próximos
- [ ] Tela de detalhes do dispositivo
- [ ] Visualização de dados dos sensores em tempo real
- [ ] Gráficos de histórico de dados
- [ ] Notificações quando dispositivo desconectar
