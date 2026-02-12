# Protocolo de Comunicação Bluetooth - GESYN IoT

## Visão Geral

Este documento descreve o protocolo de comunicação Bluetooth entre o aplicativo GESYN e os dispositivos ESP32 para configuração inicial e ativação.

## Fluxo de Ativação Completo

### 1. Cadastro do Dispositivo (App)

O usuário cadastra o dispositivo no app, gerando:

- **Device ID**: Ex: `GESYN_SOLUM-123456`
- **API Token**: Ex: `dev_abc123def456...`

### 2. Conexão Bluetooth (App → ESP32)

1. App escaneia dispositivos Bluetooth próximos
2. Usuário seleciona o ESP32 na lista
3. App conecta ao ESP32 via BLE

### 3. Configuração WiFi (App → ESP32)

**Dados Enviados pelo App:**

```json
{
  "ssid": "MinhaRedeWiFi",
  "password": "senha_wifi_123",
  "apiToken": "dev_abc123def456...",
  "deviceId": "GESYN_SOLUM-123456",
  "serverUrl": "http://3.22.64.117:3100"
}
```

**Campos:**

- `ssid`: Nome da rede WiFi
- `password`: Senha da rede WiFi
- `apiToken`: Token gerado pelo servidor para autenticação das requisições
- `deviceId`: ID único do dispositivo
- `serverUrl`: URL do servidor backend

### 4. Processamento no ESP32

O ESP32 deve:

1. Receber os dados via Bluetooth
2. Armazenar na memória não-volátil (EEPROM/SPIFFS)
3. Tentar conectar à rede WiFi com as credenciais recebidas
4. Aguardar obtenção de IP
5. Enviar resposta de confirmação via Bluetooth

### 5. Resposta do ESP32 (ESP32 → App)

**Sucesso na Conexão:**

```json
{
  "status": "connected",
  "wifiConnected": true,
  "ip": "192.168.1.100",
  "message": "Dispositivo configurado com sucesso"
}
```

**Falha na Conexão:**

```json
{
  "status": "error",
  "wifiConnected": false,
  "error": "Senha incorreta",
  "message": "Falha ao conectar à rede WiFi"
}
```

### 6. Atualização no Servidor (App → Backend)

Após receber confirmação do ESP32, o app atualiza o status no servidor:

```http
PATCH /api/v1/devices/{id}
Authorization: Bearer {userToken}
Content-Type: application/json

{
  "name": "ESP32 Sensor 01",
  "status": "ONLINE",
  "description": "Dispositivo ativado e conectado",
  "firmwareVersion": "1.0.0"
}
```

### 7. Operação Normal do ESP32

Após ativação, o ESP32 envia dados periodicamente ao servidor:

```http
POST /api/v1/devices/{deviceId}/data
Authorization: Bearer {apiToken}
Content-Type: application/json

{
  "temperature": 25.5,
  "humidity": 60.2,
  "timestamp": "2026-02-10T10:30:00Z"
}
```

---

## Implementação no ESP32 (Arduino)

### Características BLE Necessárias

```cpp
// UUIDs para o serviço BLE
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CONFIG_CHAR_UUID    "beb5483e-36e1-4688-b7f5-ea07361b26a8"  // Receber config
#define STATUS_CHAR_UUID    "1c95d5e3-d8f7-413a-bf3d-7a2e5d7be87e"  // Enviar status
```

### Código de Exemplo (Arduino/ESP32)

```cpp
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <Preferences.h>

// Configurações
Preferences preferences;
String ssid = "";
String password = "";
String apiToken = "";
String deviceId = "";
String serverUrl = "";

BLECharacteristic *statusCharacteristic;

class ConfigCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
        std::string value = pCharacteristic->getValue();

        if (value.length() > 0) {
            Serial.println("📡 Recebido via Bluetooth:");
            Serial.println(value.c_str());

            // Parse JSON
            StaticJsonDocument<512> doc;
            DeserializationError error = deserializeJson(doc, value.c_str());

            if (!error) {
                ssid = doc["ssid"].as<String>();
                password = doc["password"].as<String>();
                apiToken = doc["apiToken"].as<String>();
                deviceId = doc["deviceId"].as<String>();
                serverUrl = doc["serverUrl"].as<String>();

                // Salvar na memória não-volátil
                preferences.begin("gesyn", false);
                preferences.putString("ssid", ssid);
                preferences.putString("password", password);
                preferences.putString("apiToken", apiToken);
                preferences.putString("deviceId", deviceId);
                preferences.putString("serverUrl", serverUrl);
                preferences.end();

                Serial.println("✅ Configuração salva!");

                // Tentar conectar ao WiFi
                connectToWiFi();
            }
        }
    }
};

void connectToWiFi() {
    Serial.println("🔌 Conectando ao WiFi: " + ssid);

    WiFi.begin(ssid.c_str(), password.c_str());

    int attempts = 0;
    while (WiFi.status() != WL_CONNECTED && attempts < 20) {
        delay(500);
        Serial.print(".");
        attempts++;
    }

    StaticJsonDocument<256> response;

    if (WiFi.status() == WL_CONNECTED) {
        Serial.println("\n✅ WiFi conectado!");
        Serial.print("📍 IP: ");
        Serial.println(WiFi.localIP());

        // Enviar resposta de sucesso via Bluetooth
        response["status"] = "connected";
        response["wifiConnected"] = true;
        response["ip"] = WiFi.localIP().toString();
        response["message"] = "Dispositivo configurado com sucesso";
    } else {
        Serial.println("\n❌ Falha ao conectar WiFi");

        // Enviar resposta de erro via Bluetooth
        response["status"] = "error";
        response["wifiConnected"] = false;
        response["error"] = "Falha na conexão WiFi";
        response["message"] = "Verifique SSID e senha";
    }

    // Serializar e enviar resposta
    String responseStr;
    serializeJson(response, responseStr);
    statusCharacteristic->setValue(responseStr.c_str());
    statusCharacteristic->notify();
}

void setup() {
    Serial.begin(115200);
    Serial.println("🚀 GESYN ESP32 - Iniciando...");

    // Carregar configurações salvas
    preferences.begin("gesyn", true);
    ssid = preferences.getString("ssid", "");
    password = preferences.getString("password", "");
    apiToken = preferences.getString("apiToken", "");
    deviceId = preferences.getString("deviceId", "");
    serverUrl = preferences.getString("serverUrl", "");
    preferences.end();

    // Inicializar BLE
    BLEDevice::init("GESYN-" + deviceId);
    BLEServer *pServer = BLEDevice::createServer();
    BLEService *pService = pServer->createService(SERVICE_UUID);

    // Característica para receber configuração
    BLECharacteristic *configCharacteristic = pService->createCharacteristic(
        CONFIG_CHAR_UUID,
        BLECharacteristic::PROPERTY_WRITE
    );
    configCharacteristic->setCallbacks(new ConfigCallbacks());

    // Característica para enviar status
    statusCharacteristic = pService->createCharacteristic(
        STATUS_CHAR_UUID,
        BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY
    );

    pService->start();

    BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(SERVICE_UUID);
    pAdvertising->setScanResponse(true);
    pAdvertising->start();

    Serial.println("📡 Bluetooth ativo - Aguardando configuração...");

    // Se já tem configuração salva, tentar conectar
    if (ssid.length() > 0) {
        connectToWiFi();
    }
}

void loop() {
    // Aqui você implementa a lógica de leitura de sensores
    // e envio de dados ao servidor

    if (WiFi.status() == WL_CONNECTED) {
        // Exemplo: enviar dados a cada 10 segundos
        sendSensorData();
        delay(10000);
    }
}

void sendSensorData() {
    HTTPClient http;

    String url = serverUrl + "/api/v1/devices/" + deviceId + "/data";
    http.begin(url);
    http.addHeader("Content-Type", "application/json");
    http.addHeader("Authorization", "Bearer " + apiToken);

    StaticJsonDocument<256> doc;
    doc["temperature"] = 25.5;  // Substituir por leitura real
    doc["humidity"] = 60.2;     // Substituir por leitura real
    doc["timestamp"] = "2026-02-10T10:30:00Z";

    String payload;
    serializeJson(doc, payload);

    int httpCode = http.POST(payload);

    if (httpCode > 0) {
        Serial.printf("✅ Dados enviados: %d\n", httpCode);
    } else {
        Serial.printf("❌ Erro no envio: %s\n", http.errorToString(httpCode).c_str());
    }

    http.end();
}
```

---

## Diagrama de Sequência

```
┌─────┐          ┌─────────┐          ┌──────────┐          ┌──────────┐
│ App │          │ ESP32   │          │ WiFi AP  │          │ Backend  │
└──┬──┘          └────┬────┘          └────┬─────┘          └────┬─────┘
   │                  │                    │                     │
   │  1. Scan BLE     │                    │                     │
   ├─────────────────>│                    │                     │
   │                  │                    │                     │
   │  2. Connect      │                    │                     │
   ├─────────────────>│                    │                     │
   │                  │                    │                     │
   │  3. Send Config  │                    │                     │
   │  (SSID, Pass,    │                    │                     │
   │   Token, etc)    │                    │                     │
   ├─────────────────>│                    │                     │
   │                  │                    │                     │
   │                  │  4. Connect WiFi   │                     │
   │                  ├───────────────────>│                     │
   │                  │                    │                     │
   │                  │  5. IP Assigned    │                     │
   │                  │<───────────────────┤                     │
   │                  │                    │                     │
   │  6. BLE Response │                    │                     │
   │  (OK + IP)       │                    │                     │
   │<─────────────────┤                    │                     │
   │                  │                    │                     │
   │  7. PATCH /devices/{id}               │                     │
   │  (status: ONLINE)                     │                     │
   ├───────────────────────────────────────┴────────────────────>│
   │                  │                    │                     │
   │  8. Success      │                    │                     │
   │<─────────────────────────────────────────────────────────────┤
   │                  │                    │                     │
   │                  │  9. POST /data     │                     │
   │                  │  (periodic)        │                     │
   │                  ├────────────────────┴────────────────────>│
   │                  │                    │                     │
```

---

## Segurança

1. **API Token**: O token é único por dispositivo e nunca exposto ao usuário final
2. **WiFi Password**: Transmitido apenas uma vez via Bluetooth e armazenado criptografado
3. **HTTPS**: Em produção, usar HTTPS para comunicação ESP32 ↔ Backend
4. **BLE Pairing**: Considerar implementar pairing BLE para maior segurança

---

## Troubleshooting

### ESP32 não conecta ao WiFi

- Verificar SSID e senha
- Verificar se a rede é 2.4GHz (ESP32 não suporta 5GHz)
- Verificar intensidade do sinal

### App não encontra ESP32

- Verificar se Bluetooth está ativo no celular
- Verificar se ESP32 está em modo advertising
- Reiniciar ESP32

### Dados não chegam ao servidor

- Verificar conexão WiFi do ESP32
- Verificar se API Token está correto
- Verificar URL do servidor
