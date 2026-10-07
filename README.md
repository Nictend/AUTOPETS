# Aplicativo AUTOPETS

Este repositório contém o código-fonte do aplicativo **AUTOPETS**, desenvolvido como parte do projeto acadêmico da equipe **AUTOPETS** da **UniFAJ**.

O aplicativo foi desenvolvido utilizando **Flutter** e **Dart** e tem como objetivo fornecer uma interface para o gerenciamento e controle de um alimentador automático para animais de estimação.

Este repositório é mantido por **Nicolas G. (Nictend)** e reúne o código-fonte, estrutura e arquivos necessários para a compilação e execução do aplicativo.

> [!NOTE]
> **Nota**
>
> O projeto é desenvolvido e testado principalmente em **Linux**.  
> O Flutter possui suporte oficial para desenvolvimento em Linux, Windows e macOS, portanto o projeto também pode ser compilado nesses sistemas. Entretanto, podem existir pequenas diferenças relacionadas à configuração do Flutter SDK, Android SDK, variáveis de ambiente ou ferramentas utilizadas.

---

## Compilação e execução

### Pré-requisitos

Antes de executar o projeto, é necessário ter os seguintes componentes instalados:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Git
- Android Studio ou outro ambiente compatível com Flutter
- Android SDK
- Um emulador Android ou dispositivo físico com depuração USB habilitada

Para verificar se o ambiente está configurado corretamente, execute:

```bash
flutter doctor
```

O comando exibirá possíveis dependências ou configurações que ainda precisam ser corrigidas.

---

## Clonando o repositório

Clone o projeto utilizando o Git:

```bash
git clone https://github.com/Nictend/pet-feeder.git
```

Entre na pasta do projeto:

```bash
cd pet-feeder
```

---

## Instalando as dependências

Baixe as dependências utilizadas pelo projeto:

```bash
flutter pub get
```

---

## Executando o aplicativo

Primeiro, verifique os dispositivos disponíveis:

```bash
flutter devices
```

Caso esteja utilizando um emulador Android, os emuladores disponíveis podem ser listados com:

```bash
flutter emulators
```

Para iniciar um emulador:

```bash
flutter emulators --launch <ID_DO_EMULADOR>
```

Com o dispositivo ou emulador iniciado, execute o aplicativo:

```bash
flutter run
```

Durante a execução pelo terminal, alguns comandos úteis são:

```text
r  → Hot Reload
R  → Hot Restart
q  → Encerrar a execução
```

---

## Compilando no Windows

No Windows, recomendamos utilizar o **PowerShell** ou o terminal integrado do Android Studio.

### 1. Instalar as ferramentas necessárias

Instale:

- Git para Windows
- Flutter SDK
- Android Studio
- Android SDK

Certifique-se também de que o diretório `bin` do Flutter esteja configurado na variável de ambiente `PATH`.

Após a instalação, abra o PowerShell e execute:

```powershell
flutter doctor
```

Caso seja necessário aceitar as licenças do Android SDK:

```powershell
flutter doctor --android-licenses
```

Depois, execute novamente:

```powershell
flutter doctor
```

para verificar se o ambiente está configurado corretamente.

### 2. Clonar o projeto

```powershell
git clone https://github.com/Nictend/pet-feeder.git
cd pet-feeder
```

### 3. Instalar as dependências

```powershell
flutter pub get
```

### 4. Executar em um dispositivo ou emulador

Liste os dispositivos disponíveis:

```powershell
flutter devices
```

Para listar os emuladores:

```powershell
flutter emulators
```

Para iniciar um emulador:

```powershell
flutter emulators --launch <ID_DO_EMULADOR>
```

Depois:

```powershell
flutter run
```

### 5. Gerar o APK no Windows

Para gerar uma versão Android em modo release:

```powershell
flutter build apk --release
```

O APK será criado em:

```text
build\app\outputs\flutter-apk\app-release.apk
```

> [!IMPORTANT]
> **Importante**
>
> Essa compilação gera o aplicativo **Android (`.apk`)** utilizando um computador Windows. Ela não gera um aplicativo nativo `.exe` para Windows.

---

## Gerando o APK no Linux ou macOS

Para compilar o aplicativo Android em modo release:

```bash
flutter build apk --release
```

Após a compilação, o arquivo APK será gerado em:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Esse arquivo pode ser transferido e instalado em dispositivos Android compatíveis.

---

## Estrutura principal do projeto

O código principal da aplicação está localizado dentro da pasta:

```text
lib/
```

A estrutura é organizada da seguinte forma:

```text
lib/
├── main.dart
├── models/
├── screens/
├── services/
└── widgets/
```

- `main.dart` — ponto de entrada da aplicação.
- `models/` — modelos de dados utilizados pelo aplicativo.
- `screens/` — telas principais da interface.
- `services/` — serviços e lógica relacionada ao alimentador.
- `widgets/` — componentes visuais reutilizáveis.
