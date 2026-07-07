#!/bin/bash

# ================================================================
#  SANDBOX AR — Instalacao e Calibragem Automatica
#  Sistema : Linux Mint 22.3 Cinnamon 64-bit
#  Hardware: AMD Ryzen 7 7735U | Radeon 680M | 20 GB RAM
#  Repositorio: github.com/mauriciollsilva/sandbox
# ================================================================

GITHUB_USER="mauriciollsilva"
GITHUB_REPO="sandbox"
GITHUB_BASE="https://github.com/$GITHUB_USER/$GITHUB_REPO/releases/download/v1.0"

R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'
B='\033[0;34m'; C='\033[0;36m'; N='\033[1m'; X='\033[0m'

SRC="$HOME/src"
VRUI_DIR="$SRC/Vrui"
KINECT_DIR="$SRC/Kinect"
SANDBOX_DIR="$SRC/SARndbox"
BOXLAYOUT="$SANDBOX_DIR/etc/SARndbox-2.6/BoxLayout.txt"

cabecalho() {
    clear
    echo -e "${B}"
    echo "  ╔════════════════════════════════════════════════════════╗"
    echo "  ║            SANDBOX AR — INSTALADOR AUTOMATICO          ║"
    echo "  ║    Linux Mint 22.3  |  AMD Ryzen 7  |  Radeon 680M    ║"
    echo -e "  ║    ${C}github.com/mauriciollsilva/sandbox${B}               ║"
    echo "  ╚════════════════════════════════════════════════════════╝"
    echo -e "${X}"
}

etapa() {
    echo ""
    echo -e "${B}  ┌────────────────────────────────────────────────────────┐${X}"
    printf "${B}  │  ${N}%-54s${X}${B}  │${X}\n" "$1"
    echo -e "${B}  └────────────────────────────────────────────────────────┘${X}"
    echo ""
}

ok()    { echo -e "${G}  ✔  $1${X}"; }
info()  { echo -e "${C}  ➜  $1${X}"; }
aviso() { echo -e "${Y}  ⚠  $1${X}"; }
erro()  { echo -e "${R}  ✖  ERRO: $1${X}"; echo ""; exit 1; }
linha() { echo -e "${B}  ────────────────────────────────────────────────────────${X}"; }

pausar() {
    echo ""
    echo -e "  ${Y}Pressione ENTER para continuar...${X}"
    read -r
}

perguntar() {
    local resp
    read -rp "  $1 (s/n): " resp
    [[ "$resp" =~ ^[Ss]$ ]]
}

APENAS_CALIBRAR=false
[[ "$1" == "--recalibrar" ]] && APENAS_CALIBRAR=true
[ "$EUID" -eq 0 ] && erro "Nao execute como root/sudo."

# Garantir DISPLAY para zenity funcionar com curl
export DISPLAY=${DISPLAY:-:0}

# ── DOWNLOAD INTELIGENTE ─────────────────────────────────────────
baixar_ou_clonar() {
    local NOME="$1" ARQUIVO="$2" DESTINO="$3" GIT_URL="$4"

    if [ -d "$DESTINO" ]; then
        info "$NOME ja existe. Atualizando..."
        cd "$DESTINO" && git pull --quiet 2>/dev/null || true
        return 0
    fi

    # 1. Arquivo local (home, desktop, downloads)
    for BUSCA in "$HOME/$ARQUIVO" "$HOME/Desktop/$ARQUIVO" \
                 "$HOME/Downloads/$ARQUIVO" "$(pwd)/$ARQUIVO"; do
        if [ -f "$BUSCA" ]; then
            ok "Arquivo local encontrado: $BUSCA"
            cd "$SRC" && tar xzf "$BUSCA"
            PASTA=$(tar tzf "$BUSCA" 2>/dev/null | head -1 | cut -f1 -d"/")
            [ -d "$PASTA" ] && [ "$PASTA" != "$(basename $DESTINO)" ] \
                && mv "$PASTA" "$(basename $DESTINO)"
            return 0
        fi
    done

    # 2. Pendrive
    for BUSCA in /media/$USER/*/"$ARQUIVO" /mnt/*/"$ARQUIVO"; do
        if [ -f "$BUSCA" ]; then
            ok "Encontrado no pendrive: $BUSCA"
            cd "$SRC" && tar xzf "$BUSCA"
            PASTA=$(tar tzf "$BUSCA" 2>/dev/null | head -1 | cut -f1 -d"/")
            [ -d "$PASTA" ] && [ "$PASTA" != "$(basename $DESTINO)" ] \
                && mv "$PASTA" "$(basename $DESTINO)"
            return 0
        fi
    done

    # 3. GitHub do usuario
    info "Baixando $NOME de github.com/mauriciollsilva/sandbox..."
    if wget --timeout=60 --tries=3 -q --show-progress \
        "$GITHUB_BASE/$ARQUIVO" -O "/tmp/$ARQUIVO" 2>/dev/null; then
        ok "Download concluido!"
        cd "$SRC" && tar xzf "/tmp/$ARQUIVO"
        PASTA=$(tar tzf "/tmp/$ARQUIVO" 2>/dev/null | head -1 | cut -f1 -d"/")
        [ -d "$PASTA" ] && [ "$PASTA" != "$(basename $DESTINO)" ] \
            && mv "$PASTA" "$(basename $DESTINO)"
        rm -f "/tmp/$ARQUIVO"
        return 0
    fi

    # 4. Fallback silencioso: git clone
    aviso "Clonando $NOME diretamente..."
    git clone --depth=1 "$GIT_URL" "$DESTINO" 2>&1 | tail -3 \
        || erro "Falha ao obter $NOME. Verifique sua internet."
}

# ================================================================
#  TELA INICIAL
# ================================================================

if [ "$APENAS_CALIBRAR" = false ]; then

    cabecalho
    echo "  Este script ira:"
    echo ""
    echo "    1. Instalar todas as dependencias automaticamente"
    echo "    2. Baixar e compilar os pacotes (do seu GitHub)"
    echo "    3. Guia-lo pela calibragem passo a passo"
    echo "    4. Criar atalho na area de trabalho"
    echo ""
    echo -e "  ${Y}Para recalibrar no futuro: bash <(curl -s https://raw.githubusercontent.com/mauriciollsilva/sandbox/main/sandbox_ar.sh) --recalibrar${X}"
    echo ""
    linha
    echo ""
    echo -e "  ${N}Vamos checar o que voce tem em maos agora:${X}"
    echo ""

    echo -e "  ${C}[1/3]${X} Sensor Kinect conectado via USB?"
    perguntar "       " && TEM_KINECT=true || TEM_KINECT=false
    echo ""
    echo -e "  ${C}[2/3]${X} Projetor ligado e conectado (HDMI)?"
    perguntar "       " && TEM_PROJETOR=true || TEM_PROJETOR=false
    echo ""
    echo -e "  ${C}[3/3]${X} Caixa de areia montada e pronta?"
    perguntar "       " && TEM_AREIA=true || TEM_AREIA=false
    echo ""

    if [ "$TEM_KINECT" = true ] && [ "$TEM_PROJETOR" = true ] && [ "$TEM_AREIA" = true ]; then
        clear
        echo -e "${G}"
        echo "  ╔════════════════════════════════════════════════════════╗"
        echo "  ║                                                        ║"
        echo "  ║   UAU! Tudo pronto, hein? Que organizacao!  (^_~)     ║"
        echo "  ║                                                        ║"
        echo "  ║    Kinect ✔     Projetor ✔     Caixa de areia ✔      ║"
        echo "  ║                                                        ║"
        echo "  ╚════════════════════════════════════════════════════════╝"
        echo -e "${X}"
        echo ""
        echo "  Parece que alguem esta animado para ver areia colorida!"
        echo "  Vamos instalar tudo e depois partir para a calibragem."
        echo ""
        echo -e "  ${Y}A instalacao pode demorar 20-30 minutos (compilacao).${X}"
        echo "  Aproveita para tomar um cafe! ☕"
        echo ""
        MODO="completo"
        pausar
    else
        clear
        echo -e "${Y}"
        echo "  ╔════════════════════════════════════════════════════════╗"
        echo "  ║                                                        ║"
        echo "  ║   Relaxa! Nao precisa de nada disso agora.  (^_^)/   ║"
        echo "  ║                                                        ║"
        echo "  ╚════════════════════════════════════════════════════════╝"
        echo -e "${X}"
        echo ""
        echo "  Kinect e projetor so sao necessarios na calibragem,"
        echo "  nao na instalacao. Podemos instalar tudo agora"
        echo "  e voce calibra depois quando estiver tudo pronto!"
        echo ""
        echo -e "  ${C}O que sera feito agora:${X}"
        echo "    ✔  Instalar dependencias"
        echo "    ✔  Baixar e compilar Vrui, Kinect Package e SARndbox"
        echo "    ✗  Calibragem (fica para depois)"
        echo ""
        echo -e "  ${Y}Para calibrar depois: bash <(curl -s https://raw.githubusercontent.com/mauriciollsilva/sandbox/main/sandbox_ar.sh) --recalibrar${X}"
        echo ""
        MODO="so_instalacao"
        pausar
    fi

fi

# ================================================================
#  INSTALACAO
# ================================================================

if [ "$APENAS_CALIBRAR" = false ]; then

    cabecalho
    etapa "ETAPA 1 DE 4  -  Dependencias do sistema"

    info "Atualizando repositorios..."
    sudo apt-get update -qq && ok "Atualizado"

    info "Instalando bibliotecas..."
    sudo apt-get install -y build-essential cmake pkg-config wget bc xed git 2>/dev/null
    sudo apt-get install -y mesa-utils libgl1-mesa-dev libglu1-mesa-dev \
        libglew-dev libegl1-mesa-dev libgles2-mesa-dev 2>/dev/null
    sudo apt-get install -y libusb-1.0-0-dev libudev-dev libbluetooth-dev 2>/dev/null
    sudo apt-get install -y libjpeg-dev libpng-dev libtiff-dev zlib1g-dev \
        libv4l-dev libopenal-dev libdc1394-dev libasound2-dev \
        libxrandr-dev libxi-dev 2>/dev/null
    sudo apt-get install -y libsoundio-dev 2>/dev/null \
        || aviso "libsoundio-dev indisponivel — continuando (ok)"
    sudo usermod -aG plugdev "$USER"
    ok "Dependencias instaladas!"
    pausar

    cabecalho
    etapa "ETAPA 2 DE 4  -  Vrui VR Toolkit"
    info "Pode demorar 10-20 minutos. Todos os nucleos serao usados."
    mkdir -p "$SRC"
    baixar_ou_clonar "Vrui" "Vrui.tar.gz" "$VRUI_DIR" \
        "https://github.com/KeckCAVES/Vrui.git"
    cd "$VRUI_DIR"
    info "Aplicando correcoes de compatibilidade com Ubuntu 24.04 / GCC 13..."

    # Correcao 1: desativar sistema de dependencias incompativel
    # Neutraliza PROCESS_DEPFILE e PROCESS_PICDEPFILE (regras de plugins .so).
    # Este BasicMakefile e instalado em /usr/local/share/Vrui-4.6/make/ e
    # reutilizado por Kinect e SARndbox — sem o PICDEPFILE eles falham com
    # "*.d: No such file or directory".
    sed -i \
        's/@\$(PROCESS_DEPFILE)/true/g; s/@\$(PROCESS_PICDEPFILE)/true/g; s/@rm -f \$(DEPFILETEMPLATE)/true/g; s/-MD //g' \
        BuildRoot/BasicMakefile

    # Correcao 2: adicionar include faltante no BaseImage.h
    grep -q "cstddef" Images/BaseImage.h \
        || sed -i '/#include <GL\/gl.h>/a #include <cstddef>' Images/BaseImage.h

    ok "Correcoes aplicadas!"
    info "Compilando com $(nproc) nucleos (pode demorar 10-15 min)..."
    make -j"$(nproc)" SYSTEM_HAVE_RAWHID=0 SHELL=/bin/bash 2>&1 | tail -5

    info "Instalando Vrui..."
    sudo make install SYSTEM_HAVE_RAWHID=0 SHELL=/bin/bash 2>&1 | tail -5

    [ -f "/usr/local/share/Vrui-4.6/make/BasicMakefile" ] \
        && ok "Vrui instalado!" \
        || erro "Instalacao do Vrui falhou."

    # Legibilidade dos menus: a config padrao usa TimesBoldUpright12, uma fonte
    # bitmap de 12pt que fica borrada quando ampliada. Troca por
    # CenturySchoolbookMediumUpright (alta resolucao) e aumenta o tamanho —
    # apenas na secao Desktop, sem tocar nas secoes Vive/CAVE. Idempotente.
    VRUI_CFG="/usr/local/etc/Vrui-4.6/Vrui.cfg"
    if [ -f "$VRUI_CFG" ]; then
        info "Melhorando legibilidade dos menus (fonte de alta resolucao)..."
        awk '
            /^\tsection Desktop[ \t]*$/ { indesktop=1 }
            indesktop && /^\tsection / && $0 !~ /Desktop/ { indesktop=0 }
            indesktop && /^[ \t]*uiFontName[ \t]/       { sub(/uiFontName[ \t].*/,       "uiFontName CenturySchoolbookMediumUpright") }
            indesktop && /^[ \t]*uiFontTextHeight[ \t]/ { sub(/uiFontTextHeight[ \t].*/, "uiFontTextHeight 0.2") }
            indesktop && /^[ \t]*uiSize[ \t]/           { sub(/uiSize[ \t].*/,           "uiSize 0.09") }
            { print }
        ' "$VRUI_CFG" > /tmp/Vrui.cfg.new \
            && sudo cp /tmp/Vrui.cfg.new "$VRUI_CFG" \
            && rm -f /tmp/Vrui.cfg.new \
            && ok "Fonte da interface ajustada!" \
            || aviso "Nao foi possivel ajustar a fonte (segue normalmente)."
    fi
    pausar

    cabecalho
    etapa "ETAPA 3 DE 4  -  Kinect 3D Video Package"
    baixar_ou_clonar "Kinect" "Kinect.tar.gz" "$KINECT_DIR" \
        "https://github.com/KeckCAVES/Kinect.git"
    cd "$KINECT_DIR"
    info "Aplicando correcoes de compatibilidade com Ubuntu 24.04 / GCC 13..."
    # Mesma correcao do Vrui: desativar sistema de dependencias incompativel
    find . -name "BasicMakefile" | xargs -I{} sed -i \
        's/@\$(PROCESS_DEPFILE)/true/g; s/@\$(PROCESS_PICDEPFILE)/true/g; s/@rm -f \$(DEPFILETEMPLATE)/true/g; s/-MD //g' {}
    ok "Correcoes aplicadas!"
    info "Compilando com $(nproc) nucleos..."
    make -j"$(nproc)" SHELL=/bin/bash 2>&1 | tail -5

    # Verificar se a biblioteca foi gerada — se nao, compilar novamente
    if ! find . -name "libKinect*.so*" 2>/dev/null | grep -q .; then
        info "Recompilando para garantir geracao da biblioteca..."
        make -j"$(nproc)" SHELL=/bin/bash 2>&1 | tail -5
    fi

    info "Instalando Kinect Package..."
    sudo make install SHELL=/bin/bash 2>&1 | tail -5
    sudo make installudevrules
    sudo udevadm control --reload-rules && sudo udevadm trigger

    command -v KinectUtil &>/dev/null \
        && ok "Kinect Package instalado!" \
        || erro "Instalacao do Kinect Package falhou."
    pausar

    cabecalho
    etapa "ETAPA 4 DE 4  -  SARndbox"
    baixar_ou_clonar "SARndbox" "SARndbox.tar.gz" "$SANDBOX_DIR" \
        "https://github.com/KeckCAVES/SARndbox.git"
    cd "$SANDBOX_DIR"
    info "Compilando com $(nproc) nucleos..."
    make -j"$(nproc)" SHELL=/bin/bash 2>&1 | tail -10

    # SARndbox nao precisa de make install — roda direto da pasta bin/
    [ -f "./bin/SARndbox" ] && [ -f "./bin/CalibrateProjector" ] \
        && ok "SARndbox compilado!" \
        || erro "Compilacao do SARndbox falhou."
    mkdir -p "$(dirname "$BOXLAYOUT")"
    pausar

    if [ "$MODO" = "so_instalacao" ]; then
        cabecalho
        etapa "INSTALACAO CONCLUIDA!  ✔"
        echo ""
        ok "Tudo instalado com sucesso!"
        echo ""
        echo "  Quando tiver Kinect e projetor em maos, execute:"
        echo -e "  ${C}  bash <(curl -s https://raw.githubusercontent.com/mauriciollsilva/sandbox/main/sandbox_ar.sh) --recalibrar${X}"
        echo ""
        DESKTOP=$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")
        ATALHO="$DESKTOP/Iniciar-SandboxAR.sh"
        printf '#!/bin/bash\ncd %s\n./bin/SARndbox -uhm HeightColorMap.cpt -rer 20 60 -rs 2 -evr -0.005 -fpv\n' \
            "$SANDBOX_DIR" > "$ATALHO"
        chmod +x "$ATALHO"
        ok "Atalho criado: Iniciar-SandboxAR.sh"
        echo ""
        exit 0
    fi

fi

# ================================================================
#  CALIBRAGEM
# ================================================================

cabecalho
etapa "CALIBRAGEM  -  Visao Geral"
echo "  3 partes:"
echo ""
echo -e "    ${N}Parte 1${X} — Plano da areia     (RawKinectViewer)"
echo -e "    ${N}Parte 2${X} — Medidas da caixa   (BoxLayout.txt automatico)"
echo -e "    ${N}Parte 3${X} — Calibrar projetor  (CalibrateProjector)"
echo ""
pausar

cabecalho
etapa "CALIBRAGEM — Partes 1 e 2  -  Plano e medidas"
echo -e "  ${Y}Areia deve estar plana (ou tabua/papelao por cima).${X}"
echo ""
linha
echo ""
echo -e "  ${N}[1]${X} Mouse no centro da imagem VERDE"
echo -e "      Segure ${N}Z${X} para centralizar | scroll = zoom"
echo -e "  ${N}[2]${X} Botao DIREITO -> ${N}Average Frames${X} -> aguarde"
echo -e "  ${N}[3]${X} Segure ${N}1${X} -> ${N}Extract Planes${X} -> solte"
echo -e "      Segure ${N}1${X} e DESENHE retangulo na area verde"
echo -e "  ${N}[4]${X} Removeu tabua? Desmarque ${N}Average Frames${X},"
echo "      aguarde cor mudar, marque novamente"
echo -e "  ${N}[5]${X} Segure ${N}2${X} -> ${N}Measure 3D Positions${X} -> solte"
echo "      Clique nos 4 cantos (pressione 2 em cada):"
echo ""
echo -e "        ${Y}1o${X} Inferior ESQUERDO  ${Y}2o${X} Inferior DIREITO"
echo -e "        ${Y}3o${X} Superior ESQUERDO  ${Y}4o${X} Superior DIREITO"
echo ""
echo -e "  ${N}[6]${X} Apos os 4 cliques -> pressione ${N}ESC${X}"
echo ""
linha
echo -e "  ${R}Dados capturados automaticamente. Se falhar, janela de colagem abre.${X}"
echo ""
pausar

command -v zenity &>/dev/null || sudo apt-get install -y zenity 2>/dev/null

KINECT_LOG="/tmp/sandbox_kinect_calib.txt"
> "$KINECT_LOG"
info "Abrindo RawKinectViewer..."
echo ""

if command -v script &>/dev/null; then
    script -q -c "RawKinectViewer -compress 0" "$KINECT_LOG" 2>/dev/null \
    || RawKinectViewer -compress 0 2>&1 | tee "$KINECT_LOG"
else
    RawKinectViewer -compress 0 2>&1 | tee "$KINECT_LOG"
fi

echo ""
PLANE_LINE=$(grep "Camera-space plane equation:" "$KINECT_LOG" | tail -1)
CORNERS=$(grep -E "^\s*\(" "$KINECT_LOG" | grep -v "equation" | tail -4)

if [ -z "$PLANE_LINE" ] || [ "$(echo "$CORNERS" | wc -l)" -lt 4 ]; then
    aviso "Captura automatica falhou. Abrindo janela..."
    pausar
    MANUAL_DATA=$(zenity --text-info --editable \
        --title="Cole os dados do RawKinectViewer" \
        --width=750 --height=320 \
        --ok-label="Confirmar" --cancel-label="Cancelar" 2>/dev/null)
    [ -z "$MANUAL_DATA" ] && erro "Sem dados. Execute: bash <(curl -s https://raw.githubusercontent.com/mauriciollsilva/sandbox/main/sandbox_ar.sh) --recalibrar"
    echo "$MANUAL_DATA" > "$KINECT_LOG"
    PLANE_LINE=$(echo "$MANUAL_DATA" | grep "Camera-space plane equation:" | tail -1)
    CORNERS=$(echo "$MANUAL_DATA" | grep -E "^\s*\(" | grep -v "equation" | tail -4)
    if [ -z "$PLANE_LINE" ]; then
        FIRST=$(echo "$MANUAL_DATA" | head -1)
        echo "$FIRST" | grep -qE "\(.*,.*\)" \
            && PLANE_LINE="Camera-space plane equation: x * $FIRST" \
            && CORNERS=$(echo "$MANUAL_DATA" | tail -4)
    fi
    [ -z "$PLANE_LINE" ] || [ "$(echo "$CORNERS" | wc -l)" -lt 4 ] \
        && erro "Dados invalidos. Execute: bash <(curl -s https://raw.githubusercontent.com/mauriciollsilva/sandbox/main/sandbox_ar.sh) --recalibrar"
fi

PLANE_VECTOR=$(echo "$PLANE_LINE" | grep -oP '\([^)]+\)')
MIN_Z=$(echo "$CORNERS" | awk -F',' '{
    val=$3; gsub(/[[:space:]\(\)]/,"",val)
    if(NR==1||val+0<min+0) min=val
} END{print min}')
Z_VALUE=$(echo "$MIN_Z - 1.0" | bc)
mkdir -p "$(dirname "$BOXLAYOUT")"
{ echo "$PLANE_VECTOR, $Z_VALUE"; echo "$CORNERS"; } > "$BOXLAYOUT"
echo ""; ok "BoxLayout.txt gerado!"; linha; cat "$BOXLAYOUT"; linha; echo ""
pausar

cabecalho
etapa "CALIBRAGEM — Parte 3  -  Projetor"
echo "  ALVO: CD + papel branco + cruz no centro + fixo em haste"
echo ""
linha
echo ""
echo -e "  ${N}[1]${X} F11 = tela cheia"
echo -e "  ${N}[2]${X} Segure ${N}3${X} -> ${N}Capture${X} -> solte -> pressione ${N}4${X}"
echo -e "  ${N}[3]${X} Cruz na intersecao das linhas -> ${G}circulo verde${X} -> pressione ${N}3${X}"
echo -e "  ${N}[4]${X} Repita ${N}12 vezes${X} em ALTURAS DIFERENTES"
echo -e "  ${N}[5]${X} Sucesso: ${R}linhas vermelhas${X} rastreiam o alvo ✔"
echo ""
linha
echo ""
perguntar "Alvo pronto? Calibrar o projetor agora?" && {
    pausar; cd "$SANDBOX_DIR"
    sudo ./bin/CalibrateProjector
    ok "Projetor calibrado!"
    pausar
} || { aviso "Pulado. Calibre depois: bash <(curl -s https://raw.githubusercontent.com/mauriciollsilva/sandbox/main/sandbox_ar.sh) --recalibrar"; }

# ================================================================
#  FIM
# ================================================================

cabecalho
etapa "TUDO PRONTO!  ✔"
echo -e "  ${C}Para iniciar:${X} cd $SANDBOX_DIR && ./bin/SARndbox"
echo ""
linha

# Detectar pasta da area de trabalho (funciona em portugues e ingles)
DESKTOP=$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")
ATALHO="$DESKTOP/Iniciar-SandboxAR.sh"
CURL_CMD="bash <(curl -s https://raw.githubusercontent.com/mauriciollsilva/sandbox/main/sandbox_ar.sh)"

# Criar atalho com menu de opcoes
cat > "$ATALHO" << ATALHO_EOF
#!/bin/bash
export DISPLAY=\${DISPLAY:-:0}

SANDBOX_DIR="$SANDBOX_DIR"
CURL_CMD="bash <(curl -s https://raw.githubusercontent.com/mauriciollsilva/sandbox/main/sandbox_ar.sh)"

OPCAO=\$(zenity --list \
    --title="Sandbox AR" \
    --text="O que deseja fazer?" \
    --column="Opcao" \
    --column="Descricao" \
    "1" "Executar a projecao (equipamento ja calibrado)" \
    "2" "Recalibrar completo (equipamento foi movido)" \
    "3" "Calibrar apenas o projetor — o CD!  (^_~)" \
    --width=500 --height=250 2>/dev/null)

case "\$OPCAO" in
    "1")
        cd "\$SANDBOX_DIR"
        ./bin/SARndbox -uhm HeightColorMap.cpt -rer 20 60 -rs 2 -evr -0.005 -fpv
        ;;
    "2")
        zenity --question \
            --title="Recalibragem Completa" \
            --text="O equipamento foi desmontado ou movido de lugar?\n\nSe apenas foi desligado, nao precisa recalibrar — use a opcao 1!" \
            --ok-label="Sim, foi movido — Recalibrar" \
            --cancel-label="Nao, so estava desligado" \
            --width=400 2>/dev/null \
        && eval "\$CURL_CMD --recalibrar" \
        || { cd "\$SANDBOX_DIR" && ./bin/SARndbox -uhm HeightColorMap.cpt -rer 20 60 -rs 2 -evr -0.005 -fpv; }
        ;;
    "3")
        zenity --info \
            --title="Calibragem do Projetor" \
            --text="Prepare o alvo:  CD + papel branco + cruz no centro  (^_~)\n\nPronto? Vamos la!" \
            --ok-label="Estou pronto!" \
            --width=350 2>/dev/null
        cd "\$SANDBOX_DIR"
        sudo ./bin/CalibrateProjector
        ;;
esac
ATALHO_EOF

chmod +x "$ATALHO"

ok "Atalho criado na area de trabalho: Iniciar-SandboxAR.sh"
echo ""
echo -e "  ${Y}Ao clicar no atalho voce vera um menu com opcoes:${X}"
echo "    1. Executar a projecao"
echo "    2. Recalibrar completo"
echo "    3. Calibrar so o projetor  (^_~)"
echo ""
echo -e "${B}  ══════════════════════════════════════════════════════════${X}"
echo -e "${N}               Boa diversao com a Sandbox AR!  ⛰  (^_~)${X}"
echo -e "${B}  ══════════════════════════════════════════════════════════${X}"
echo ""
