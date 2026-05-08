# SANDBOX AR — Como subir para o GitHub e usar offline

## Seu repositório
**github.com/mauriciollsilva/sandbox**

---

## PASSO 1 — Gerar os pacotes de backup

Com internet, execute no Linux Mint:

```bash
bash backup_sandbox.sh
```

Isso cria a pasta `~/sandbox-pacotes/` com os arquivos:
- `Vrui.tar.gz`
- `Kinect.tar.gz`
- `SARndbox.tar.gz`
- `sandbox_ar.sh`
- `sandbox_ar_pendrive.sh`

---

## PASSO 2 — Configurar o Git e subir os arquivos

No terminal do Linux Mint:

```bash
# Configurar seu Git (só na primeira vez)
git config --global user.name "mauriciollsilva"
git config --global user.email "seu@email.com"

# Entrar na pasta dos pacotes
cd ~/sandbox-pacotes

# Iniciar repositório local e subir para o GitHub
git init
git add sandbox_ar.sh sandbox_ar_pendrive.sh backup_sandbox.sh
git commit -m "Adiciona scripts do Sandbox AR"
git branch -M main
git remote add origin https://github.com/mauriciollsilva/sandbox.git
git push -u origin main
```

> Os arquivos `.tar.gz` são grandes demais para commit direto.
> Eles precisam ir como **Release** (próximo passo).

---

## PASSO 3 — Subir os .tar.gz como Release no GitHub

Os pacotes `.tar.gz` vão como **Release** (suportam arquivos grandes):

1. Acesse **github.com/mauriciollsilva/sandbox**
2. Clique em **Releases** (coluna direita)
3. Clique em **"Create a new release"**
4. **Tag:** `v1.0`
5. **Title:** `Pacotes Sandbox AR`
6. Arraste os 3 arquivos para a área de upload:
   - `Vrui.tar.gz`
   - `Kinect.tar.gz`
   - `SARndbox.tar.gz`
7. Clique em **"Publish release"**

Após isso os arquivos ficam disponíveis em:
```
https://github.com/mauriciollsilva/sandbox/releases/download/v1.0/Vrui.tar.gz
https://github.com/mauriciollsilva/sandbox/releases/download/v1.0/Kinect.tar.gz
https://github.com/mauriciollsilva/sandbox/releases/download/v1.0/SARndbox.tar.gz
```

---

## PASSO 4 — Copiar para o pendrive

```bash
# Descobrir o nome do pendrive
ls /media/$USER/

# Copiar tudo (substitua NOME_PENDRIVE pelo nome real)
cp ~/sandbox-pacotes/Vrui.tar.gz        /media/$USER/NOME_PENDRIVE/
cp ~/sandbox-pacotes/Kinect.tar.gz      /media/$USER/NOME_PENDRIVE/
cp ~/sandbox-pacotes/SARndbox.tar.gz    /media/$USER/NOME_PENDRIVE/
cp ~/sandbox-pacotes/sandbox_ar_pendrive.sh /media/$USER/NOME_PENDRIVE/
```

---

## COMO INSTALAR A PARTIR DO PENDRIVE

No computador de destino, conecte o pendrive e execute:

```bash
# Copiar arquivos para home
cp /media/$USER/NOME_PENDRIVE/*.tar.gz $HOME/
cp /media/$USER/NOME_PENDRIVE/sandbox_ar_pendrive.sh $HOME/

# Executar instalador offline
bash $HOME/sandbox_ar_pendrive.sh
```

O instalador encontra os `.tar.gz` automaticamente — **sem internet**.

---

## COMO INSTALAR A PARTIR DO SEU GITHUB

Em qualquer Linux Mint com internet:

```bash
# Baixar o instalador do seu GitHub
wget https://raw.githubusercontent.com/mauriciollsilva/sandbox/main/sandbox_ar.sh

# Executar (baixa os pacotes automaticamente do seu GitHub)
bash sandbox_ar.sh
```

---

## LÓGICA DE BUSCA DO INSTALADOR (sandbox_ar.sh)

```
1. Arquivo local em ~/  ~/Desktop/  ~/Downloads/
2. Pendrive em /media/$USER/*/
3. GitHub: github.com/mauriciollsilva/sandbox (releases/v1.0)
4. Fallback: git clone dos repositórios originais
```

---

## RECALIBRAR APÓS MOVER O EQUIPAMENTO

```bash
# Versão online
bash sandbox_ar.sh --recalibrar

# Versão pendrive
bash sandbox_ar_pendrive.sh --recalibrar
```

---

*Sandbox AR | Linux Mint 22.3 | AMD Ryzen 7 7735U | Radeon 680M*
*github.com/mauriciollsilva/sandbox*
