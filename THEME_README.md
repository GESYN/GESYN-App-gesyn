# Gesyn App - High-Tech UI Theme

## 🎨 Design Implementado

Tema futurista high-tech inspirado em interfaces modernas com:

### Paleta de Cores

- **Background**: Preto (#000000)
- **Primary**: Roxo vibrante (#7C4DFF)
- **Secondary**: Azul (#448AFF)
- **Accent Colors**:
  - Roxo escuro (#4A148C)
  - Azul escuro (#1A237E)
  - Cinza escuro (#212121, #424242)

### Características Visuais

#### 1. **Background Animado Metálico**

- Ondas metálicas animadas com gradientes roxo/azul
- Efeito shimmer sutil
- Versão `subtle` para telas de conteúdo (Home, Profile)
- Versão completa para telas de autenticação (Login, Register)

#### 2. **Tipografia**

- **Títulos**: Orbitron (fonte futurista/tecnológica)
- **Corpo**: Inter (fonte moderna e legível)
- Google Fonts integrado

#### 3. **Componentes**

- Cards com bordas arredondadas e borda roxa brilhante
- Botões com cantos arredondados
- Input fields com fundo escuro transparente
- Chips coloridos por role (Admin = vermelho, User = verde)

### Telas Atualizadas

#### Login Screen (`login_screen.dart`)

- Background animado completo
- Ícone de cadeado destacado
- Campos com ícones prefixados
- Layout centralizado e responsivo (max-width: 400px)

#### Home Screen (`home_screen.dart`)

- Background sutil (mais discreto)
- Card de perfil com avatar (iniciais)
- Chip de role colorido
- Botões de ação em Wrap
- Mensagem de boas-vindas quando não autenticado

#### Profile Screen (`profile_screen.dart`)

- Background sutil
- Cards organizados por seção
- Layout de informações com labels e valores
- Exibe todos os campos do usuário (incluindo nationality, document, address)

### Dependências Adicionadas

```yaml
dependencies:
  google_fonts: ^6.1.0 # Tipografia moderna
  flutter_animate: ^4.5.0 # Animações (preparado para uso futuro)
  http: ^1.2.0 # Atualizado para compatibilidade
```

### Como Usar

#### Executar o App

```bash
cd '/home/imply/Área de trabalho/app gsyn/gesyn_app'
flutter run -d web-server --web-hostname localhost --web-port 50508
```

Acesse: **http://localhost:50508**

#### Tema Claro (Opcional)

No `main.dart`, altere:

```dart
themeMode: ThemeMode.light,  // Muda para tema claro
```

### Estrutura de Arquivos

```
lib/
├── theme/
│   └── app_theme.dart          # Tema dark/light com paleta high-tech
├── widgets/
│   ├── animated_background.dart # Background animado metálico
│   └── gs_modal.dart
├── screens/
│   ├── login_screen.dart       # Com background animado
│   ├── home_screen.dart        # Com background sutil
│   └── profile_screen.dart     # Com background sutil
└── main.dart                    # Configurado com AppTheme.darkTheme
```

### Próximos Passos (Opcionais)

1. **Animações avançadas**: Usar `flutter_animate` para transições de entrada/saída
2. **Gráficos/Charts**: Adicionar visualizações de dados
3. **Modo claro otimizado**: Melhorar paleta do tema claro
4. **Responsividade**: Ajustes para tablets e desktop
5. **Micro-interações**: Hover effects, ripples customizados

### Notas Técnicas

- Background usa `CustomPainter` com animação contínua (8s loop)
- Tema usa Material 3 (`useMaterial3: true`)
- Cards com transparência e bordas iluminadas
- Paleta otimizada para contraste em tela escura

---

**Desenvolvido com Flutter 🚀**
