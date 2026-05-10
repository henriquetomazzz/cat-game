# Pegue o Gato 🐱

Jogo de tabuleiro em grade hexagonal onde o jogador controla um gato e tenta escapar para a borda, enquanto a IA (Cerca) tenta prender o gato colocando obstáculos.

## Como rodar na máquina

### 1. Instalar o Flutter

Acesse https://docs.flutter.dev/get-started/install e siga os passos para o sistema operacional do computador (Windows, Linux ou macOS).

**Resumo rápido (Linux):**
```bash
# Baixar o Flutter
git clone https://github.com/flutter/flutter.git -b stable ~/flutter

# Adicionar ao PATH
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Verificar se está tudo ok
flutter doctor
```

No **Windows**, baixe o ZIP do site do Flutter e extraia em `C:\flutter`. Depois adicione `C:\flutter\bin` ao PATH do sistema.

### 2. Clonar o projeto

```bash
git clone https://github.com/henriquetomazzz/cat-game.git
cd cat-game
```

### 3. Rodar o jogo

Com um celular conectado via USB (com depuração USB ativada) ou um emulador aberto:

```bash
flutter run
```

Se quiser rodar no navegador (mais fácil para testar):

```bash
flutter run -d chrome
```

### 4. Como jogar

- Toque em um hexágono azul adjacente ao gato para movê-lo
- O objetivo é chegar até a borda do tabuleiro
- A IA (Cerca) coloca bloqueios vermelhos para te impedir
- Se o gato não tiver mais caminho até a borda, a Cerca vence

Divirta-se!
