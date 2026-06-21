<div align="center">

# 🌑 DarkHUB

**Universal Script para Roblox — Poderoso, Modular e Furtivo**

[![Version](https://img.shields.io/badge/version-2.0-blueviolet?style=for-the-badge)](https://github.com/)
[![Lua](https://img.shields.io/badge/Lua-5.1-blue?style=for-the-badge&logo=lua)](https://www.lua.org/)
[![Platform](https://img.shields.io/badge/platform-Roblox-red?style=for-the-badge)](https://www.roblox.com/)
[![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)](LICENSE)

</div>

---

## 📖 Sobre

**DarkHUB** é um script universal para Roblox construído sobre a biblioteca [Fluent UI](https://github.com/dawid-scripts/Fluent), com foco em **funcionalidade, estabilidade e stealth**. Ele funciona na maioria dos jogos sem necessidade de configuração específica.

> Todas as instâncias criadas pelo script recebem nomes gerados aleatoriamente a cada sessão, eliminando fingerprints fixos detectáveis por anti-cheats.

---

## ✨ Funcionalidades

<details>
<summary><b>👁️ ESP — Player Visibility</b></summary>

| Feature | Descrição |
|---|---|
| **Enable ESP** | Highlight colorido nos personagens de todos os jogadores |
| **Team Check** | Exclui jogadores do mesmo time do ESP |
| **Fill Color** | Cor de preenchimento do highlight (personalizável) |
| **Outline Color** | Cor do contorno do highlight (personalizável) |
| **Name Tags** | Exibe o nome dos jogadores acima do personagem |
| **Health Bar** | Barra de vida em tempo real acima de cada jogador |

</details>

<details>
<summary><b>🏃 Movement — Movimentação</b></summary>

| Feature | Descrição |
|---|---|
| **Speed Hack** | Aumenta a velocidade de caminhada (configurável de 16 a 300) |
| **NoClip** | Atravessa paredes e objetos sólidos |
| **Fly** | Voo livre com controles WASD + Space/Shift |
| **Fly Speed** | Velocidade do voo (10–300) |
| **Vehicle Fly** | Voo dentro de veículos |
| **Infinity Jump** | Pulo infinito sem restrição de estado |
| **Walk on Air** | Andar no ar sem cair |
| **Anti-Ragdoll** | Desativa o estado de ragdoll |
| **Anti-Fall Damage** | Restaura HP após queda |
| **Click TP** | Clique no mapa para teleportar |
| **TP to Spawn** | Teleporte direto ao spawn do mapa |
| **Waypoints** | Salve, selecione e delete waypoints customizados |
| **Anti-AFK** | Previne desconexão por inatividade |

</details>

<details>
<summary><b>🌍 World — Mundo</b></summary>

| Feature | Descrição |
|---|---|
| **Fullbright** | Remove escuridão e torna o mapa totalmente iluminado |
| **No Fog** | Remove névoa do ambiente |
| **Remove Effects** | Desativa efeitos de pós-processamento |
| **Freecam** | Câmera livre pelo mapa (independente do personagem) |
| **Freecam Speed** | Velocidade da câmera livre (0.1–10) |

</details>

<details>
<summary><b>👤 Player — Utilitários do Jogador</b></summary>

| Feature | Descrição |
|---|---|
| **Player TP** | Teleporte para qualquer jogador no servidor |
| **Player Spy** | Mira a câmera em outro jogador para espioná-lo |
| **Health Restore** | Restaura HP ao máximo a cada frame |
| **Forcefield** | Campo de força invisível ao redor do personagem |
| **Infinite Health** | MaxHealth e Health definidos como `math.huge` |
| **Disable Dead State** | Previne o estado de morte do Humanoid |
| **Hook TakeDamage** | Intercepta e bloqueia dano via metamétodo |

</details>

<details>
<summary><b>🛡️ Bypass — Anti-Detecção</b></summary>

| Feature | Descrição |
|---|---|
| **Fingerprint Wipe** | Apaga globals do executor, falsifica `identifyexecutor`, `checkcaller`, `iscclosure`, etc. Hookeia `loadstring` e `require` para bloquear ACs |
| **Anti-Kick & Ban** | Bloqueia `Kick()`, `BootFromGame()`, `KickPlayer()` e FireServer com nomes de kick/ban via `__namecall` hook |
| **Anti-Cheat Breaker** | Varre todos os serviços, desabilita scripts de AC por nome/source, destrói remotes e re-scana em intervalo aleatório (370–620 ticks) |
| **Full Scan & Disable** | Varredura única no PlayerGui, Backpack, PlayerScripts e ReplicatedStorage |
| **Anti-Cheat Monitor** | Monitora `DescendantAdded` e nuke automático de scripts de AC inseridos dinamicamente |
| **Remote Report Block** | Bloqueia `FireServer`/`InvokeServer` de remotes com nomes de anti-cheat |
| **HTTP Block** | Intercepta `GetAsync`/`PostAsync` para URLs suspeitas de AC/ban |
| **Speed Protect** | Bloqueia mudanças não autorizadas de `WalkSpeed` via `__newindex` |
| **Speed Spoof** | Retorna `16` para leituras de `WalkSpeed` via `__index` |
| **NoClip Protect** | Impede re-ativação de `CanCollide` nas partes do personagem |
| **Fly Protect** | Guard loop que reativa o fly se for desabilitado |
| **God Protect** | Bloqueia zeragem de `Health`/`MaxHealth` via hook |
| **Disconnect AC Signals** | Desconecta todos os signals do Humanoid/HRP que ACs usam para monitorar |
| **Activate All Spoofs** | Ativa todos os spoofs e proteções com um clique |
| **Lag Switch** | Ancora o HRP para simular lag de rede |

</details>

<details>
<summary><b>⚔️ Fling — Arremesso de Jogadores</b></summary>

| Feature | Descrição |
|---|---|
| **Fling Target** | Arremessa um jogador específico selecionado |
| **Velocity Multiplier** | Multiplica a força do fling (0.1–5x) |
| **Touch Fling** | Arremessa qualquer jogador que tocar no personagem |
| **Fling All** | Loop automático que arremessa todos os jogadores no servidor |
| **Anti-Fling** | Protege contra flings recebidos via `NoCollisionConstraint` + velocity cap |
| **Velocity Limit** | Limite de velocidade para o anti-fling (20–300) |

</details>

<details>
<summary><b>📦 External Tools</b></summary>

| Script | Descrição |
|---|---|
| **Infinity Yield** | Carrega o Infinity Yield diretamente pelo menu |

</details>

---

## 🚀 Como Usar

**1.** Abra seu executor favorito (Synapse X, KRNL, Fluxus, etc.)

**2.** Cole o loadstring abaixo no executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/DarkModeBR/DarkHUB/main/DarkHUB.lua"))()
```

**3.** Execute e o menu abrirá automaticamente.

**4.** Use `RightControl` para minimizar/restaurar o menu a qualquer momento.

---

## ⚙️ Requisitos

| Requisito | Detalhe |
|---|---|
| **Executor** | Qualquer executor com suporte a `getrawmetatable`, `setreadonly`, `getnamecallmethod`, `newcclosure`, `getgenv` |
| **Plataforma** | PC (Windows) |
| **Conexão** | Necessária para carregar a UI (Fluent) e scripts externos |

> ⚠️ Funções de Bypass avançadas (Fingerprint Wipe, Speed Spoof, Hook TakeDamage) requerem executor compatível com metamétodos. Executores gratuitos podem ter suporte parcial.

---

## 🎨 Interface

O DarkHUB utiliza a biblioteca **[Fluent UI](https://github.com/dawid-scripts/Fluent)** com o tema `Darker`.

- Minimize/maximize com `RightControl`
- Interface totalmente responsiva e com suporte a transparência desativada para melhor performance
- Notificações integradas para feedback de todas as ações

---

## 🔒 Stealth & Anti-Detecção

O DarkHUB implementa diversas técnicas para reduzir a detectabilidade:

- **Nomes de instâncias aleatórios por sessão** — ForceField, BillboardGui, BodyVelocity e BodyGyro recebem nomes únicos gerados a cada execução
- **Keys do `getgenv()` randomizadas** — as referências internas no ambiente global nunca têm nome fixo
- **Jitter no scan interval** — o re-scan do breaker ocorre em intervalos variáveis (370–620 ticks) para evitar padrões temporais
- **Proteção da GUI** — tentativa automática de mover o menu para `gethui()` / `CoreGui` com `syn.protect_gui` quando disponível
- **HTTP Interceptor** — bloqueia requisições HTTP de scripts de detecção para servidores externos
- **Spoof de `__tostring`** — impede identificação de hooks via inspeção do ambiente

---

<div align="center">

**Feito com 🖤 — DarkHUB Universal Script**

</div>
