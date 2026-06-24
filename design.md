---
version: alpha
name: web-pharmachatbot
description: >-
  Sistema de design extraído das telas Login, Dashboard (v2) e PharmaConnector
  (AgentConnectorPanel) do web-pharmachatbot. React 18 + Vite + MUI v5 + Emotion +
  styled-components. Os tokens-fonte vivem em src/styles/global.ts (CSS variables,
  tema light/dark). Login e PharmaConnector extraídos de origin/main; Dashboard de
  origin/feat/dashboard-v2.
colors:
  # Marca (primária) — fonte: src/styles/global.ts (light theme)
  primary-lighter: '#f58aa0'
  primary-light: '#f15976'
  primary-base: '#e6284a'
  primary-dark: '#cc2443'
  primary-darker: '#a31c34'
  # Tints de primary (escala fina) — superfícies/badges WABA; dark mode invertido em global.ts
  primary-50: '#fff0f2'   # fundo muito leve (botão/item selecionado WABA)
  primary-100: '#ffd6dc'  # tint leve (badge de template / hover)
  primary-300: '#f58aa0'  # borda leve (WabaTemplateButton border)
  primary-600: '#cc2443'  # texto em fundo claro (primary-dark)
  primary-700: '#a31c34'  # texto em fundo mais escuro (primary-darker)
  # Tints semânticos (alertas de superfície) — usados nos alertas WABA; dark mode em global.ts
  error-50: '#fff0f0'     # fundo do alerta de janela expirada
  error-600: '#E31C3D'    # texto/ícone do alerta de expiração (= danger-base)
  warning-50: '#fffbeb'   # fundo do alerta de janela pendente
  warning-600: '#CA9318'  # texto/ícone do alerta pendente (= warning-dark)
  # Tom extra-claro de superfície (abaixo de gray-100)
  gray-50: '#FCFCFD'      # fundo de PreviewCard no WabaTemplatePicker
  # Feedback
  success-light: '#94BFA2'
  success-base: '#3bb354'
  success-dark: '#3AC589'
  danger-light: '#F97474'
  danger-base: '#E31C3D'
  danger-dark: '#B31E22'
  warning-light: '#FAD980'
  warning-base: '#FDB81E'
  warning-dark: '#CA9318'
  info-light: '#9BDAF1'
  info-base: '#02BFE7'
  info-dark: '#00A6D2'
  # Neutros (escala cinza light)
  white: '#ffffff'
  black: '#000000'
  gray-100: '#F8F9FA'
  gray-200: '#E9ECEF'
  gray-300: '#DEE2E5'
  gray-400: '#D1D5DA'
  gray-500: '#B8BEC5'
  gray-600: '#9D9AAD'
  gray-700: '#888599'
  gray-800: '#737185'
  gray-900: '#605E70'
  gray-1000: '#3A3847'
  # Texto (apelidos usados nas telas)
  text-strong: '#3A3847'   # FieldLabel, input text
  text-default: '#605E70'  # títulos / DARK_TEXT
  text-muted: '#737185'    # MUTED_TEXT / mensagens
  text-placeholder: '#9D9AAD'
  # Handoff (PharmaConnector) — tons fixos fora da escala de marca
  handoff-success: '#10B981'
  handoff-warning: '#F59E0B'
  # Marca externa
  whatsapp: '#25D366'
  # Estados de botão (verde/vermelho de sucesso/erro)
  state-success: '#16a34a'
  state-error: '#dc2626'
  # Categorias de relatório (Relatórios v2)
  report-cat-atendimento-accent: '#e6284a'
  report-cat-atendimento-accent2: '#f15976'
  report-cat-clientes-accent: '#f0508a'
  report-cat-clientes-accent2: '#ff7eb0'
  report-cat-engajamento-accent: '#f06a45'
  report-cat-engajamento-accent2: '#ff9166'
  report-cat-financeiro-accent: '#c4407e'
  report-cat-financeiro-accent2: '#e668a8'
typography:
  font-family-default: 'Montserrat, sans-serif'
  font-family-title: 'Poppins, sans-serif'
  font-family-subtitle: 'Inter, sans-serif'
  font-family-mono: 'ui-monospace, SFMono-Regular, Menlo, monospace'
  # Variantes (fontSize em rem; pesos abaixo)
  display:   { fontSize: 1.75rem, fontWeight: 700, lineHeight: 1.2 }   # Login Title, StatCard Value
  h2:        { fontSize: 1.1875rem, fontWeight: 800, letterSpacing: -0.01em } # Modal title
  card-title:{ fontSize: 1rem, fontWeight: 800, letterSpacing: -0.01em }
  body-md:   { fontSize: 1rem, fontWeight: 400, lineHeight: 1.5 }
  body-sm:   { fontSize: 0.875rem, fontWeight: 400 }
  body-xs:   { fontSize: 0.8125rem, fontWeight: 400, lineHeight: 1.5 }
  label:     { fontSize: 0.875rem, fontWeight: 600 }
  overline:  { fontSize: 0.6875rem, fontWeight: 700, letterSpacing: 0.1em } # UPPERCASE labels
  button:    { fontSize: 1rem, fontWeight: 600 }
rounded:
  none: 0px
  xs: 2.5px
  sm: 5px
  md: 8px
  input: 0.75rem      # 12px — campos e botões das telas refatoradas
  card: 18px          # CARD_RADIUS (PharmaConnector)
  hero: 22px          # HERO_RADIUS
  lg: 20px
  glass: 1.5rem       # 24px — cartão de login/painéis
  full: 9999px
  circle: 50%
spacing:
  px: 1px
  s1: 0.25rem
  s2: 0.50rem
  s3: 0.75rem
  s4: 1rem
  s5: 1.25rem
  s6: 1.50rem
  s8: 2rem
  handoff-gap: 18px
components:
  button-primary:
    backgroundColor: '{colors.primary-base}'
    textColor: '{colors.white}'
    typography: '{typography.button}'
    rounded: '{rounded.input}'
    padding: '0.95rem 1rem'
    width: '100%'
    # hover -> {colors.primary-dark}; shadow 0 8px 22px rgba(230,40,74,0.28); active scale(0.99)
  button-secondary:
    backgroundColor: '{colors.white}'
    textColor: '{colors.text-default}'
    rounded: '12px'
    padding: '0.6rem 1rem'
    typography: '{typography.body-sm}'
    # border 1px {colors.gray-* via rgba(0,0,0,0.06)}; hover bg mix(primary 4%)
  button-tertiary:
    backgroundColor: 'transparent'
    textColor: '{colors.text-default}'
    rounded: '12px'
  input:
    backgroundColor: 'rgba(255,255,255,0.85)'
    textColor: '{colors.text-strong}'
    rounded: '{rounded.input}'
    padding: '0.875rem 1rem'
    height: 'auto'
    # border 1px rgba(0,0,0,0.06); focus ring 0 0 0 3px rgba(230,40,74,0.12)
  card:
    backgroundColor: '{colors.white}'
    rounded: '{rounded.card}'
    padding: '18px 22px'
    # border 1px rgba(0,0,0,0.06); hover shadow {SHADOW_MD}
  chip:
    rounded: '{rounded.full}'
    padding: '2px 8px'
    typography: '{typography.overline}'
---

## Overview

O **web-pharmachatbot** é um console operacional (atendimento, automação e
integração de dados) para farmácias. A personalidade visual é **clara, confiante e
calorosa**: fundo claro, superfícies brancas, **vermelho-coral de marca
(`#e6284a`)** como cor de ação única e dominante, e neutros levemente arroxeados
(`#605E70` / `#737185`) para o texto. As telas recentes (Login e PharmaConnector)
adotam **glassmorphism sutil** (vidro fosco, sombras difusas, cantos arredondados
generosos) e **microanimações** que reforçam estado (sucesso, erro, carregamento)
sem ruído. O Dashboard v2 prioriza **densidade de dados legível**: cartões brancos
em grade, números grandes e uma paleta categórica vibrante reservada exclusivamente
para os gráficos.

Resposta emocional desejada: **acolhimento na entrada (Login)**, **clareza e
controle na operação (PharmaConnector / Dashboard)**. Público: operadores e gestores
de farmácia, em desktop predominantemente (com responsividade até mobile).

Fonte de verdade dos tokens: `src/styles/global.ts` (CSS custom properties, temas
`light`/`dark` via atributo `data-theme`). Não há `createTheme` do MUI — os
componentes MUI herdam o default e o estilo real vem de styled-components + as CSS
vars. Há também um `src/styles/global.css` com um conjunto Material-like (fonte
Inter, primária azul) usado **apenas** por features de encarte/newsletter — **não**
se aplica às três telas deste documento.

## Colors

### Marca (ação)
Uma única família de marca conduz toda a ação. `primary-base` `#e6284a` é o botão
primário, links e foco; `primary-dark` `#cc2443` é o hover.

| Token | Light | Uso |
|---|---|---|
| `primary-lighter` | `#f58aa0` | tints/realces |
| `primary-light` | `#f15976` | — |
| `primary-base` | `#e6284a` | botão primário, links, foco, seleção |
| `primary-dark` | `#cc2443` | hover do primário |
| `primary-darker` | `#a31c34` | pressionado/contraste |

> As cores de marca vêm de variáveis de ambiente (`VITE_COLOR_PRIMARY_*`) com os
> hex acima como **fallback** — i.e. são white-labeláveis por instância.

### Feedback (semânticas)
| Papel | light | base | dark |
|---|---|---|---|
| success | `#94BFA2` | `#3bb354` | `#3AC589` |
| danger | `#F97474` | `#E31C3D` | `#B31E22` |
| warning | `#FAD980` | `#FDB81E` | `#CA9318` |
| info | `#9BDAF1` | `#02BFE7` | `#00A6D2` |

**Tons de estado em botões/banners** (fora da escala semântica padrão, herdados do
novo Login): sucesso `#16a34a`, erro `#dc2626`, e o verde/âmbar de handoff do
PharmaConnector — sucesso `#10B981`, aviso `#F59E0B`.

### Neutros e texto
Escala `gray-100 #F8F9FA` → `gray-1000 #3A3847`. Apelidos de texto usados nas telas:
título/`DARK_TEXT` `#605E70`, secundário/`MUTED_TEXT` `#737185`, texto forte de
input/label `#3A3847`, placeholder `#9D9AAD`. Borda suave universal:
`rgba(0,0,0,0.06)`.

### Paletas de dados — Dashboard v2 (uso exclusivo em gráficos)
Categórica principal (pizza/canais), em ordem:
`#0097b2` · `#ea4d62` · `#fdbd5c` · `#ff65c3` · `#8c52ff` · `#d0ed57` · `#8884d8` ·
`#fa8072` · `#0cc1e0` · `#b8860b`.
Variante "quantidade por canal": `#fdbd5c` · `#ff65c3` · `#8c52ff` · `#d0ed57` ·
`#8884d8` · `#fa8072` · `#0cc1e0` · `#b8860b` · `#889E73` · `#A94A4A`.
Séries de serviço (verdes): `#83E2A0` · `#3bb354` · `#258C44`. Linha
positivo/negativo: `#00bf63` / `#ff3131`. Eixos e rótulos de gráfico: `#888599`;
tooltip: fundo `#00000090`, texto `#ffffff`.

> ⚠️ A paleta de dados é **categórica e vibrante de propósito** e vive isolada nos
> gráficos. **Não** use essas cores em botões, textos ou superfícies de UI — a UI usa
> apenas marca + neutros + semânticas.

### Ícones/gradientes de categoria — Relatórios v2

Tokens de **ícone/gradiente de categoria do catálogo de Relatórios v2**. Cada
categoria possui dois tons (`accent` e `accent2`) que compõem o gradiente do ícone
via `linear-gradient(135deg, accent, accent2)`.

| Categoria | `accent` | `accent2` |
|---|---|---|
| `report-cat-atendimento` | `#e6284a` (primary-base) | `#f15976` (primary-light) |
| `report-cat-clientes` | `#f0508a` | `#ff7eb0` |
| `report-cat-engajamento` | `#f06a45` | `#ff9166` |
| `report-cat-financeiro` | `#c4407e` | `#e668a8` |

> ⚠️ **Uso exclusivo nos ícones/gradientes do catálogo de relatórios — nunca em
> botões, texto ou superfícies de UI.** Para ação, use sempre `primary-base`; para
> semântica, use a escala `success/danger/warning/info`.

### Dark mode
Há tema escuro completo (`html[data-theme='dark']`): `white`→`#2d2e2f`,
`black`→`#ffffff`, escala de cinza invertida, marca mantida. Ative respeitando
`prefers-color-scheme`; as telas usam as vars, então herdam automaticamente.

## Typography

Três famílias: **Montserrat** (padrão, corpo e UI), **Poppins** (títulos, opcional)
e **Inter** (subtítulos, opcional). Montserrat é carregada como fonte variável
(peso 100–900). O reset global aplica `Roboto` como último fallback em `*`.

| Nível | Tamanho | Peso | Onde |
|---|---|---|---|
| Display | `1.75rem` (28px) | 700–800 | título do Login; valor de StatCard (800) |
| H2 / Modal | `1.1875rem` (19px) | 800 | cabeçalho de modal |
| Card title | `1rem` | 800 | títulos de cards (MethodCard, SuccessHero) |
| Body md | `1rem` | 400 | texto de botão, corpo |
| Body sm | `0.875rem` (14px) | 400–600 | labels, subtítulos, links |
| Body xs | `0.8125rem` (13px) | 400 | descrições, hints |
| Overline | `0.6875rem` (11px) | 700 | rótulos UPPERCASE, `letter-spacing: 0.1em` |

Escala completa de tamanhos disponível em vars: `--font-size-xxs 0.625rem` …
`--font-size-xl8 6rem`. Pesos: lighter, regular, medium, bold. Line-heights:
`none 100%`, `shorter 120%`, `short 140%`, `base 180%`, `tall 200%`. Texto
monoespaçado (`ui-monospace`) é reservado para nomes de arquivo, caminhos, tokens e
linhas de mapeamento no PharmaConnector.

## Layout

Grade fluida baseada em **flex/grid** com `gap` em rem. Responsividade por
`@media (max-width)` — breakpoints recorrentes: **640px**, **768px**, **900px**,
**1024px**, **1100px**, **1200px**. O `font-size` raiz escala por viewport
(67.75% ≤600px → 81.5% ≥1280px), então rems "respiram" com a tela.

- **Login** — `min-height: 100vh`, conteúdo **centralizado** (flex center/center),
  imagem de fundo `cover`. Cartão: `max-width: 37rem`, `height: 40rem`
  (mobile 36rem), com `perspective: 1600px` para o flip 3D. Padding do cartão
  `2.75rem 2.5rem 2.25rem`; formulário em coluna com `gap: 0.75rem`.
- **PharmaConnector** — workspace em colunas (`WorkspaceLeftRail` / `WorkspaceMain`
  / `WorkspaceAside`), seções empilhadas com `gap: 18px` (`HANDOFF_GAP`). Grades de
  cards 3→2→1 colunas (`StatGrid`/`CardsGrid` em 1023px e 640px). Wizard em grade
  `repeat(4, 1fr)`. Filtro de empresa `max-width: 28rem`.
- **Dashboard v2** — `GridStaticsLayout`: `grid-template-columns: 25rem auto`,
  linhas `minmax(21rem,21rem)`, `gap: var(--spacing-s4)` (16px); colapsa para 1
  coluna ≤1100px. Cards de métricas em grade `repeat(5,1fr)` que reflui para
  `repeat(6,1fr)`/colunas únicas ≤1200/900px. `gap` típico **1rem** (containers) e
  **20px** (grade de dados).

Alinhamento: títulos e textos de cartão à esquerda; conteúdo de entrada (Login) e
estados vazios centralizados; ações de rodapé de modal justificadas (`space-between`
ou `flex-end`).

## Responsivo & Overlays

A tela **Atendimentos v2** adota um comportamento responsivo no padrão WhatsApp:
em telas pequenas as colunas (lista ↔ conversa) viram **painéis em tela cheia /
bottom-sheets** sobre um dimmer, em vez de coexistirem lado a lado.

### Breakpoints nomeados

| Nome | Faixa |
|---|---|
| `small` | `< 480px` |
| `mobile` | `< 768px` |
| `tablet` | `768px – 1023px` |
| `desktop` | `≥ 1024px` |

> Esses são os breakpoints **canônicos do responsivo de Atendimentos v2**. Os
> valores recorrentes citados em **Layout** (640/768/900/1024/1100/1200) seguem
> válidos para as grades de Dashboard/PharmaConnector; novas telas responsivas
> usam os nomes acima.

### Backdrop / dimmer

| Token | Valor | Uso |
|---|---|---|
| `--color-backdrop` | `rgba(0, 0, 0, 0.5)` | dimmer atrás de overlay/sheet (mobile/tablet) |

> `--color-backdrop` é o **único** valor de cor novo desta seção — fonte em
> `src/styles/global.ts`. Não introduza outro preto translúcido para dimmer;
> reuse este token.

### Sheet (painel em tela cheia / bottom-sheet)

- **Raio superior:** reusa `var(--border-radius-hero)` (**22px**) nos cantos de topo do
  bottom-sheet; painel em tela cheia pode dispensar raio.
- **Sombra:** reusa `SHADOW_LG` (ver Elevation & Depth) — sem sombra nova.
- **Altura:** em **mobile/tablet** use `100dvh` / `100svh` para o painel cheio —
  **nunca** `100vh` (evita o pulo da barra de URL móvel). O `100svh` é o piso
  seguro; `100dvh` acompanha a viewport dinâmica.

### Durações de slide

| Transição | Token | Valor |
|---|---|---|
| Entrada (slide-in) do painel/sheet | `var(--animation-normal)` | 300ms |
| Saída (slide-out) do painel/sheet | `var(--animation-fast)` | 200ms |

Easing `cubic-bezier(0.4, 0, 0.2, 1)` (material). **Toda** essa animação de slide
é obrigatoriamente embrulhada em `@media (prefers-reduced-motion: no-preference)`;
sob movimento reduzido a troca de painel é instantânea.

## Elevation & Depth

Profundidade por **sombras difusas de baixa opacidade** + vidro fosco, não por
bordas pesadas. Tokens globais: `--box-shadow-base: 0 2px 8px rgba(99,99,99,0.2)`,
`--box-shadow-thick: rgba(0,0,0,0.15) 0 5px 15px`.

Sombras das telas refatoradas:
- **Card padrão (hover)** `SHADOW_MD`: `0 8px 24px -8px rgba(26,19,32,0.12), 0 2px 6px rgba(26,19,32,0.05)`.
- **Elevação grande** `SHADOW_LG`: `0 24px 60px -20px color-mix(primary 25%), 0 8px 20px -8px rgba(26,19,32,0.10)`.
- **Cartão de vidro (Login / painéis)**: `0 24px 60px rgba(15,15,30,0.12), inset 0 1px 0 rgba(255,255,255,0.45)` + `backdrop-filter: blur(18px) saturate(180%)` sobre `rgba(255,255,255,0.18)`.
- **Botão primário**: `0 8px 22px rgba(230,40,74,0.28)` (sombra colorida da marca).
- **Foco de input**: anel `0 0 0 3px rgba(230,40,74,0.12)`.
- **Seleção de card**: anel `0 0 0 4px color-mix(primary 8%)`.

Hover de cards eleva levemente (`translateY(-1px)` a `-2px`) junto com a sombra.

## Shapes

Cantos consistentemente arredondados, escalando com o tamanho do elemento:

| Token | Valor | Uso |
|---|---|---|
| `xs` | 2.5px | detalhes |
| `sm` | 5px | indicadores de wizard, banners |
| `md` | 8px | popovers, containers pequenos |
| `input` | 0.75rem (12px) | **inputs e botões** das telas novas |
| `card` | 18px | cards (PharmaConnector) |
| `hero` | 22px | hero/destaque |
| `lg` | 20px | — |
| `glass` | 1.5rem (24px) | cartão de login e painéis de vidro |
| `full` | 9999px | chips, badges, avatares de status, pílulas |
| `circle` | 50% | ícones circulares |

Bordas: largura padrão 1px; borda suave `rgba(0,0,0,0.06)`; tracejada
(`2px dashed`) para zonas de "scan/drop" de arquivos.

## Components

### Botão primário (`button-primary`)
Largura total, `padding: 0.95rem 1rem`, `border-radius: 0.75rem`, fundo
`primary-base`, texto branco, peso 600, `font-size: 1rem`, sombra de marca
`0 8px 22px rgba(230,40,74,0.28)`. **Hover** → `primary-dark`. **Active** →
`scale(0.99)`. Ícone à direita desliza `translateX(5px)` no hover (transição
`0.25s cubic-bezier(0.4,0,0.2,1)`). Estados embutidos com cor + animação:
`loading` (spinner), `success` `#16a34a` (+ `pulseSuccess`), `error` `#dc2626`
(+ `shake`). Implementado igual no Login (`SubmitButton`) e no PharmaConnector
(`PrimaryActionButton`).

### Botão secundário / terciário
Secundário: fundo branco, borda `rgba(0,0,0,0.06)`, `padding: 0.6rem 1rem`,
`radius 12px`, peso 600; hover funde marca a 4% no fundo e 20% na borda. Terciário:
transparente sem borda, hover com fundo `color-mix(primary 6%)`.

**Botão de ícone circular** (ações de composer "+"/emoji em Atendimentos v2):
`2rem` quadrado, `radius full`, fundo transparente; **hover** ganha fundo circular
cinza-neutro `gray-200` (`--aliases-200`) e ícone `gray-700`; **clique** dispara o
pulse `pressPulse` (ver Animation & Motion). Para ação primária de envio, o botão é
sólido vermelho (ver botão primário) — o botão de **gravar áudio** ocioso reusa
exatamente esse fundo/estados (vermelho + hover/press do envio).

### Inputs
Container flex com ícone (lucide, `size 18`, `strokeWidth 1.8`) + campo. Fundo
`rgba(255,255,255,0.85)`, `radius 0.75rem`, borda `rgba(0,0,0,0.06)`,
`padding 0.875rem 1rem`. **Foco** (`:focus-within`): fundo branco, borda
`primary-base`, anel `0 0 0 3px rgba(230,40,74,0.12)`. **Inválido**: borda/ícone
`#dc2626` + anel vermelho. Placeholder `#9D9AAD`. Autofill neutralizado.

### Cards
Fundo branco, borda suave, `radius 18px`, `padding 18px 22px`; hover ganha
`SHADOW_MD` (e `translateY` nos StatCards). Cards selecionáveis (MethodCard,
DriverCard): fundo em gradiente sutil de marca (`color-mix primary 6% → white`),
borda de marca 35% e anel de seleção. **StatCard**: `min-height 130px`, valor
`1.75rem/800`, ícone em quadro `34px` `radius 10px` tingido por tom
(primary/success/warning a 10%), pílula de tendência arredondada.

### Chips / Badges / Pílulas de status
`border-radius: 999px`, `padding 2px 8px`, texto `overline` (11px/700, uppercase,
tracking 0.1em). Badge "online/offline" usa `success-lightest`/`error-lightest` de
fundo com texto `*-darker`.

### Cabeçalho de modal / Wizard (PharmaConnector)
Ícone em quadro `46px` `radius 14px` com **gradiente de marca**
(`135deg, primary-base → primary-dark`) e sombra colorida. Stepper: dots `24px`
circulares (todo `gray-200`, atual `primary-base` com anel `color-mix 16%`, done
`#10B981`), conectores `2px`.

### Segmented control / StatusTabs (Atendimentos v2)
Trilho cinza (`var(--color-gray-200)`, `border-radius: var(--border-radius-lg)`).
Em vez de acender o fundo de cada botão, usa um **único indicador branco deslizante**
(pílula absoluta) que se move entre abas via `transform: translateX` + `width`
(ver indicador deslizante em Animation & Motion). Os botões ficam com fundo sempre
transparente; apenas `font-weight` distingue a aba ativa.

### Gráficos (Dashboard v2)
Recharts. Cartões brancos `radius 7px/10px`. Use as **paletas de dados** desta
spec; eixos/grades em `#888599`; tooltip escuro translúcido (`#00000090` / texto
branco). Cores positivas/negativas: `#00bf63` / `#ff3131`.

## Animation & Motion

Durações canônicas (vars): `instant 0` · `faster 100ms` · `fast 200ms` ·
`normal 300ms` · `slow 400ms` · `slower 500ms`. **Todas** as animações decorativas
são embrulhadas em `@media (prefers-reduced-motion: no-preference)`.

Transições de UI típicas: `0.15s–0.18s ease` (hover de cards, cores de borda/fundo),
`0.25s ease` (cor/fundo/sombra de botão), `transform 0.05s` (feedback de press).

**Transição de conteúdo de lista** (troca de aba/filtro em listas re-renderizadas
em memória, ex.: abas de Atendimentos v2 "Atendendo/Aguardando/Fluxo/Grupos"):
duração `list-content 150ms` (entre `faster 100ms` e `fast 200ms`), easing
`cubic-bezier(0.4, 0, 0.2, 1)` (padrão de saída/entrada de material). Aplica-se ao
**wrapper** do conteúdo (não item a item, para não custar por linha em listas
virtualizadas), via `key` da aba ativa + keyframe de entrada `fadeInList`
(opacidade `0→1` + `translateY(4px→0)`, sutil). Sempre sob
`prefers-reduced-motion: no-preference`.

Keyframes nomeados (compartilhados Login + PharmaConnector):
- `fadeIn` / `revealUp` — entrada de seções: opacidade 0→1 + `translateY(8px→0)`,
  `0.4s–0.5s`, com `animation-delay` escalonado por seção (stagger).
- `fadeInList` — entrada do conteúdo de lista na troca de aba/filtro: opacidade
  `0→1` + `translateY(4px→0)`, `150ms cubic-bezier(0.4,0,0.2,1)` (token
  `list-content`); aplicado no wrapper keyed pela aba ativa (Atendimentos v2).
- **Indicador deslizante do segmented control (StatusTabs — Atendimentos v2):**
  único elemento `div` (pílula branca, `var(--color-white)`, `var(--border-radius-lg)`)
  posicionado via `position: absolute` dentro do trilho; a posição e largura são
  medidas em JS e aplicadas como `transform: translateX(…)` + `width`. Transição
  `slow 400ms cubic-bezier(0.4, 0, 0.2, 1)` aplicada a `transform` e `width`,
  exclusivamente sob `@media (prefers-reduced-motion: no-preference)`. No primeiro
  paint (mount) a transição é suprimida (`$animate: false`) para o indicador não
  deslizar do canto; em movimento reduzido a troca é instantânea.
- `attachmentMenuIn` — entrada de popover/menu flutuante ancorado a um botão
  (ex.: menu de anexos do "+" no composer de Atendimentos v2): opacidade `0→1` +
  `scale(0.95→1)`, `faster 100ms` `cubic-bezier(0.4,0,0.2,1)`, com
  `transform-origin` no canto adjacente ao botão (ex.: `bottom left`).
- `pressPulse` — pulse de micro-interação no clique de botões de ícone circulares
  (ex.: "+"/emoji do composer): **encolhe e volta** — `scale 1 → 0.9 → 1`,
  `fast 200ms` `cubic-bezier(0.4,0,0.2,1)`; disparado pelo `:active` (não por estado
  React, para não vazar em re-render). Sempre sob `prefers-reduced-motion: no-preference`.
- `spin` — spinner de loading, `0.8s linear infinite`.
- `popIn` — ícone de sucesso/erro, `0.45s cubic-bezier(0.34,1.56,0.64,1)` (overshoot).
- `shake` — erro de botão, `0.55s cubic-bezier(0.36,0.07,0.19,0.97)`.
- `pulseSuccess` / `pulseRing` / `pulseRingPrimary` — anel pulsante de destaque (CTA,
  WhatsApp), `1.1s`–`2.4s`.
- `phoneVibrate` — microvibração do ícone de WhatsApp na recuperação de senha, `3s`.
- **Flip 3D do cartão de Login** — `transform: rotateY(180deg)` em
  `0.85s cubic-bezier(0.65,0,0.35,1)`, com `backface-visibility: hidden` e troca de
  `visibility` atrasada (`0.425s`). Efeito de máquina de escrever no título (lib
  `typewriter-effect`, delay 55ms / deleteSpeed 30ms).

## Do's and Don'ts

**Do**
- Use `primary-base` como **única** cor de ação; hover sempre `primary-dark`.
- Arredonde inputs/botões com `0.75rem` e cards com `18px`; pílulas/badges com `full`.
- Prefira sombras difusas (`SHADOW_MD`/`SHADOW_LG`) a bordas grossas para hierarquia.
- Padronize estados de ação assíncrona com o tripé `loading → success(#16a34a) →
  error(#dc2626)` e suas animações.
- Sempre proteja animações com `prefers-reduced-motion`.
- Texto: título/`#605E70`, secundário/`#737185`; mono só para dados técnicos.
- Reaproveite os tokens (`SHADOW_MD`, `CARD_RADIUS`, `SOFT_BORDER`, CSS vars) em vez
  de hex avulsos.

**Don't**
- Não use as cores categóricas de gráfico em botões, texto ou superfícies de UI.
- Não introduza um novo verde/vermelho de sucesso/erro — reaproveite `#16a34a` /
  `#dc2626` (ações) e a escala semântica `success/danger` (banners).
- Não misture o conjunto de `global.css` (Inter/azul Material) com estas telas — ele
  é exclusivo de encarte/newsletter.
- Não use cantos vivos (`radius 0`) em cards, inputs ou botões.
- Não empilhe sombras opacas pesadas; mantenha opacidades baixas (≤0.2).
- Não anime sem fallback de movimento reduzido nem ultrapasse `500ms` em microinterações.
