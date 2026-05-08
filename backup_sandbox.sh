#!/bin/bash

# ================================================================
#  SANDBOX AR — Script de Backup dos Pacotes
#  Gera os arquivos .tar.gz para guardar no GitHub e no pendrive
#
#  !! ALTERE AS DUAS LINHAS ABAIXO COM SEU USUARIO DO GITHUB !!
# ================================================================
GITHUB_USER="SEU_USUARIO"           # <-- coloque seu usuario do GitHub
GITHUB_REPO="sandbox-ar"            # <-- coloque o nome do seu repositorio
# ================================================================

R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'
B='\033[0;34m'; C='\033[0;36m'; N='\033[1m'; X='\033[0m'

ok()    { echo -e "${G}  ✔  $1${X}"; }
info()  { echo -e "${C}  ➜  $1${X}"; }
aviso() { echo -e "${Y}  ⚠  $1${X}"; }
erro()  { echo -e "${R}  ✖  ERRO: $1${X}"; exit 1; }
linha() { echo -e "${B}  ──────────────────────────────────────────────────${X}"; }

SAIDA="$HOME/sandbox-pacotes"
SRC="/tmp/sandbox-backup-src"

clear
echo -e "${B}"
echo "  ╔════════════════════════════════════════════════════════╗"
echo "  ║         SANDBOX AR — GERADOR DE PACOTES BACKUP         ║"
echo "  ╚════════════════════════════════════════════════════════╝"
echo -e "${X}"
echo ""
echo "  Este script vai:"
echo "    1. Clonar os repositorios necessarios"
echo "    2. Empacotar em arquivos .tar.gz"
echo "    3. Copiar o instalador principal"
echo "    4. Mostrar como enviar para o GitHub e pendrive"
echo ""
echo -e "  ${Y}Os arquivos serao salvos em:${X}"
echo -e "  ${C}  $SAIDA${X}"
echo ""
echo ""
read -rp "  Pressione ENTER para comecar..." _

# Verificar git
command -v git &>/dev/null || { sudo apt-get install -y git 2>/dev/null; }

mkdir -p "$SAIDA" "$SRC"
cd "$SRC"

# ── CLONAR E EMPACOTAR VRUI ──────────────────────────────────────
echo ""
info "Clonando Vrui..."
rm -rf "$SRC/Vrui"
git clone --depth=1 https://github.com/KeckCAVES/Vrui.git "$SRC/Vrui" 2>&1 | tail -3 \
    || erro "Falha ao clonar Vrui."

info "Empacotando Vrui.tar.gz..."
tar czf "$SAIDA/Vrui.tar.gz" -C "$SRC" Vrui
ok "Vrui.tar.gz criado ($(du -sh $SAIDA/Vrui.tar.gz | cut -f1))"

# ── CLONAR E EMPACOTAR KINECT ────────────────────────────────────
echo ""
info "Clonando Kinect Package..."
rm -rf "$SRC/Kinect"
git clone --depth=1 https://github.com/KeckCAVES/Kinect.git "$SRC/Kinect" 2>&1 | tail -3 \
    || erro "Falha ao clonar Kinect."

info "Empacotando Kinect.tar.gz..."
tar czf "$SAIDA/Kinect.tar.gz" -C "$SRC" Kinect
ok "Kinect.tar.gz criado ($(du -sh $SAIDA/Kinect.tar.gz | cut -f1))"

# ── CLONAR E EMPACOTAR SARNDBOX ──────────────────────────────────
echo ""
info "Clonando SARndbox..."
rm -rf "$SRC/SARndbox"
git clone --depth=1 https://github.com/KeckCAVES/SARndbox.git "$SRC/SARndbox" 2>&1 | tail -3 \
    || erro "Falha ao clonar SARndbox."

info "Empacotando SARndbox.tar.gz..."
tar czf "$SAIDA/SARndbox.tar.gz" -C "$SRC" SARndbox
ok "SARndbox.tar.gz criado ($(du -sh $SAIDA/SARndbox.tar.gz | cut -f1))"

# ── COPIAR INSTALADOR ────────────────────────────────────────────
echo ""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/sandbox_ar.sh" ]; then
    cp "$SCRIPT_DIR/sandbox_ar.sh" "$SAIDA/sandbox_ar.sh"
    ok "sandbox_ar.sh copiado"
else
    aviso "sandbox_ar.sh nao encontrado na mesma pasta. Copie manualmente para $SAIDA/"
fi

# ── LIMPEZA ──────────────────────────────────────────────────────
rm -rf "$SRC"

# ── RESUMO ───────────────────────────────────────────────────────
echo ""
linha
echo ""
echo -e "  ${G}${N}Arquivos gerados em $SAIDA:${X}"
echo ""
ls -lh "$SAIDA"
echo ""
linha
echo ""
echo -e "  ${N}TAMANHO TOTAL:${X} $(du -sh $SAIDA | cut -f1)"
echo ""
echo ""

# ── INSTRUCOES RAPIDAS ───────────────────────────────────────────
echo -e "${B}  ════════ PROXIMOS PASSOS ════════${X}"
echo ""
echo -e "  ${N}1. GITHUB — Criar release e subir os arquivos:${X}"
echo ""
echo "     a) Acesse: github.com/$GITHUB_USER/$GITHUB_REPO"
echo "     b) Clique em 'Releases' > 'Create a new release'"
echo "     c) Tag: v1.0  |  Titulo: Pacotes Sandbox AR"
echo "     d) Arraste os 4 arquivos de $SAIDA para a area de upload"
echo "     e) Clique em 'Publish release'"
echo ""
echo -e "  ${N}2. PENDRIVE — Copiar os arquivos:${X}"
echo ""
echo "     Conecte o pendrive e execute:"
echo -e "     ${C}cp -r $SAIDA/* /media/\$USER/NOME_DO_PENDRIVE/${X}"
echo ""
echo "     Ou abra o gerenciador de arquivos e copie a pasta"
echo -e "     ${C}$SAIDA${X} para o pendrive."
echo ""
echo -e "  ${N}3. INSTALAR A PARTIR DO PENDRIVE:${X}"
echo ""
echo "     No computador destino, conecte o pendrive e execute:"
echo -e "     ${C}cp /media/\$USER/NOME_DO_PENDRIVE/*.tar.gz \$HOME/${X}"
echo -e "     ${C}cp /media/\$USER/NOME_DO_PENDRIVE/sandbox_ar.sh \$HOME/${X}"
echo -e "     ${C}bash \$HOME/sandbox_ar.sh${X}"
echo ""
echo "     O instalador encontra os .tar.gz automaticamente em \$HOME"
echo "     e nao precisa baixar nada da internet!"
echo ""
echo -e "${B}  ════════════════════════════════════════════════${X}"
echo ""
