# Prato Limpo — Entenda o que você come

Aplicativo Flutter focado em auxiliar usuários a interpretar rótulos, registrar refeições e conversar com uma nutricionista virtual. Construído com arquitetura limpa, suporte offline e integrações com Google Gemini, ML Kit e Hive.

## Funcionalidades Principais

- 📷 **Scanner Inteligente**: reconhece textos de rótulos com OCR local e envia para a Nutri-IA gerar análises coloridas, com sumário em HTML e dicas de substituição.
- 🗓️ **Diário Alimentar (PRO)**: acompanha metas diárias e recebe lançamentos por voz ou importados do scanner. Dados persistidos localmente em Hive.
- 🤖 **Nutri-IA (PRO)**: chat interativo com respostas amigáveis, botões de sugestão e histórico salvo localmente.
- ⚙️ **Configurações**: metas nutricionais, monitores de restrições e gerenciamento de plano.
- 🔒 **Offline first**: dados do usuário disponíveis sem internet, com respostas de demonstração quando o serviço de IA não está acessível.

## Estrutura do Projeto

```
lib/
 ├─ application/
 ├─ domain/
 ├─ infrastructure/
 ├─ models/
 ├─ providers/
 ├─ screens/
 ├─ services/
 └─ utils/
```

## Pré-requisitos

- Flutter (canal stable) mais recente.
- Chave de API do Google Gemini definida na variável de ambiente `GEMINI_API_KEY` ou fornecida pelo usuário nas configurações (mock).

## Configuração

1. Execute `flutter pub get` para instalar as dependências.
2. (Opcional) Gere código com `flutter pub run build_runner build --delete-conflicting-outputs` se modificar provedores anotados.
3. Rode `flutter run` para iniciar o aplicativo.

## Build

```
flutter build apk --debug
```

## Licença

Projeto educacional para demonstração técnica.

