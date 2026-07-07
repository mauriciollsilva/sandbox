#!/bin/bash

# ================================================================
#  SANDBOX AR — Instalacao e Calibragem Simplificada
#  Versao: Instalacao via Pendrive (offline)
#  Sistema : Linux Mint 22.3 Cinnamon 64-bit
#  Hardware: AMD Ryzen 7 7735U | Radeon 680M | 20 GB RAM
# ================================================================

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
    echo "  ║         SANDBOX AR — INSTALACAO VIA PENDRIVE           ║"
    echo "  ║         Instalacao e Calibragem Simplificada           ║"
    echo "  ║    Linux Mint 22.3  |  AMD Ryzen 7  |  Radeon 680M    ║"
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

# ── LOCALIZAR PACOTES NO PENDRIVE ────────────────────────────────
localizar_pacote() {
    local ARQUIVO="$1"
    for BUSCA in \
        "$HOME/$ARQUIVO" \
        "$HOME/Desktop/$ARQUIVO" \
        "$HOME/Downloads/$ARQUIVO" \
        "$(pwd)/$ARQUIVO" \
        /media/$USER/*/"$ARQUIVO" \
        /mnt/*/"$ARQUIVO"
    do
        [ -f "$BUSCA" ] && echo "$BUSCA" && return 0
    done
    return 1
}

extrair_pacote() {
    local NOME="$1" ARQUIVO="$2" DESTINO="$3"

    if [ -d "$DESTINO" ]; then
        info "$NOME ja esta instalado."
        return 0
    fi

    CAMINHO=$(localizar_pacote "$ARQUIVO")
    if [ -z "$CAMINHO" ]; then
        erro "Arquivo $ARQUIVO nao encontrado! Verifique se o pendrive esta conectado e se os arquivos estao presentes."
    fi

    ok "Encontrado: $CAMINHO"
    info "Extraindo $NOME..."
    cd "$SRC"
    tar xzf "$CAMINHO"
    PASTA=$(tar tzf "$CAMINHO" 2>/dev/null | head -1 | cut -f1 -d"/")
    [ -d "$PASTA" ] && [ "$PASTA" != "$(basename $DESTINO)" ] \
        && mv "$PASTA" "$(basename $DESTINO)"
    ok "$NOME extraido!"
}

# ================================================================
#  TELA INICIAL
# ================================================================

if [ "$APENAS_CALIBRAR" = false ]; then

    cabecalho
    echo "  Este script instala a Sandbox AR a partir dos arquivos"
    echo "  presentes no pendrive ou na pasta atual."
    echo ""
    echo "  Nenhuma conexao com a internet e necessaria."
    echo ""
    echo -e "  ${Y}Arquivos necessarios:${X}"
    echo "    Vrui.tar.gz | Kinect.tar.gz | SARndbox.tar.gz"
    echo ""
    echo -e "  ${Y}Para recalibrar no futuro:${X}"
    echo -e "  ${C}  bash sandbox_ar_pendrive.sh --recalibrar${X}"
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
        echo "  Instalacao offline via pendrive + calibragem completa!"
        echo ""
        echo -e "  ${Y}Isso pode demorar 20-30 minutos (compilacao).${X}"
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
        echo "  Kinect e projetor so sao necessarios na calibragem."
        echo "  Vamos instalar tudo agora e voce calibra depois!"
        echo ""
        echo -e "  ${C}O que sera feito agora:${X}"
        echo "    ✔  Instalar dependencias"
        echo "    ✔  Extrair e compilar os pacotes do pendrive"
        echo "    ✗  Calibragem (fica para depois)"
        echo ""
        echo -e "  ${Y}Para calibrar depois:${X}"
        echo -e "  ${C}  bash sandbox_ar_pendrive.sh --recalibrar${X}"
        echo ""
        MODO="so_instalacao"
        pausar
    fi

    # Verificar se os pacotes estao acessiveis antes de comecar
    cabecalho
    etapa "Verificando pacotes no pendrive..."

    TODOS_OK=true
    for PKG in Vrui.tar.gz Kinect.tar.gz SARndbox.tar.gz; do
        CAMINHO=$(localizar_pacote "$PKG")
        if [ -n "$CAMINHO" ]; then
            ok "$PKG → $CAMINHO"
        else
            echo -e "${R}  ✖  $PKG — NAO ENCONTRADO${X}"
            TODOS_OK=false
        fi
    done

    echo ""
    if [ "$TODOS_OK" = false ]; then
        erro "Um ou mais pacotes nao foram encontrados. Verifique se o pendrive esta conectado e os arquivos presentes."
    fi
    ok "Todos os pacotes localizados!"
    pausar

fi

# ================================================================
#  INSTALACAO
# ================================================================

if [ "$APENAS_CALIBRAR" = false ]; then

    cabecalho
    etapa "ETAPA 1 DE 4  -  Dependencias do sistema"
    info "Atualizando lista de pacotes..."
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
    mkdir -p "$SRC"
    extrair_pacote "Vrui" "Vrui.tar.gz" "$VRUI_DIR"
    cd "$VRUI_DIR"
    info "Aplicando correcoes de compatibilidade com Ubuntu 24.04 / GCC 13..."
    # Neutraliza PROCESS_DEPFILE e PROCESS_PICDEPFILE (regras de plugins .so).
    # Este BasicMakefile e instalado em /usr/local/share/Vrui-4.6/make/ e
    # reutilizado por Kinect e SARndbox — sem o PICDEPFILE eles falham com
    # "*.d: No such file or directory".
    sed -i \
        's/@\$(PROCESS_DEPFILE)/true/g; s/@\$(PROCESS_PICDEPFILE)/true/g; s/@rm -f \$(DEPFILETEMPLATE)/true/g; s/-MD //g' \
        BuildRoot/BasicMakefile
    grep -q "cstddef" Images/BaseImage.h \
        || sed -i '/#include <GL\/gl.h>/a #include <cstddef>' Images/BaseImage.h
    ok "Correcoes aplicadas!"
    info "Compilando com $(nproc) nucleos (pode demorar 10-15 min)..."
    make -j"$(nproc)" SYSTEM_HAVE_RAWHID=0 SHELL=/bin/bash 2>&1 | tail -5
    sudo make install SYSTEM_HAVE_RAWHID=0 SHELL=/bin/bash 2>&1 | tail -5
    [ -f "/usr/local/share/Vrui-4.6/make/BasicMakefile" ] \
        && ok "Vrui instalado!" \
        || erro "Instalacao do Vrui falhou."
    pausar

    cabecalho
    etapa "ETAPA 3 DE 4  -  Kinect 3D Video Package"
    extrair_pacote "Kinect" "Kinect.tar.gz" "$KINECT_DIR"
    cd "$KINECT_DIR"
    info "Aplicando correcoes de compatibilidade com Ubuntu 24.04 / GCC 13..."
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

    sudo make install SHELL=/bin/bash 2>&1 | tail -5
    sudo make installudevrules
    sudo udevadm control --reload-rules && sudo udevadm trigger
    command -v KinectUtil &>/dev/null \
        && ok "Kinect Package instalado!" \
        || erro "Instalacao do Kinect Package falhou."
    pausar

    cabecalho
    etapa "ETAPA 4 DE 4  -  SARndbox"
    extrair_pacote "SARndbox" "SARndbox.tar.gz" "$SANDBOX_DIR"
    cd "$SANDBOX_DIR"
    info "Compilando com $(nproc) nucleos..."
    make -j"$(nproc)" SHELL=/bin/bash 2>&1 | tail -10
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
        echo "  Quando tiver Kinect e projetor prontos, execute:"
        echo -e "  ${C}  bash sandbox_ar_pendrive.sh --recalibrar${X}"
        echo ""
        ATALHO="$HOME/Desktop/Iniciar-SandboxAR.sh"
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
    [ -z "$MANUAL_DATA" ] && erro "Sem dados. Execute: bash sandbox_ar_pendrive.sh --recalibrar"
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
        && erro "Dados invalidos. Execute: bash sandbox_ar_pendrive.sh --recalibrar"
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
} || { aviso "Pulado. Calibre depois: bash sandbox_ar_pendrive.sh --recalibrar"; }

# ================================================================
#  FIM
# ================================================================

cabecalho
etapa "TUDO PRONTO!  ✔"
echo -e "  ${C}Simples:${X}     cd $SANDBOX_DIR && ./bin/SARndbox"
echo -e "  ${C}Recomendado:${X} ./bin/SARndbox -uhm HeightColorMap.cpt -rer 20 60 -rs 2 -evr -0.005 -fpv"
echo ""
linha

ATALHO="$HOME/Desktop/Iniciar-SandboxAR.sh"
printf '#!/bin/bash\ncd %s\n./bin/SARndbox -uhm HeightColorMap.cpt -rer 20 60 -rs 2 -evr -0.005 -fpv\n' \
    "$SANDBOX_DIR" > "$ATALHO"
chmod +x "$ATALHO"

ok "Atalho criado: Iniciar-SandboxAR.sh"
echo ""
echo -e "${B}  ══════════════════════════════════════════════════════════${X}"
echo -e "${N}               Boa diversao com a Sandbox AR!  ⛰  (^_~)${X}"
echo -e "${B}  ══════════════════════════════════════════════════════════${X}"
echo ""
