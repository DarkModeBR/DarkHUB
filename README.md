<div align="center">

# 🌑 DarkHUB — Universal Script

**Um hub universal para Roblox, leve, organizado e poderoso — construído sobre a UI [Fluent](https://github.com/dawid-scripts/Fluent).**

[![Lua](https://img.shields.io/badge/Made%20with-Lua-000080?style=for-the-badge&logo=lua&logoColor=white)](https://www.lua.org/)
[![Roblox](https://img.shields.io/badge/Platform-Roblox-FF4B4B?style=for-the-badge&logo=robloxstudio&logoColor=white)](https://www.roblox.com/)
[![UI](https://img.shields.io/badge/UI-Fluent-1e1e2e?style=for-the-badge)](https://github.com/dawid-scripts/Fluent)
[![License](https://img.shields.io/badge/Licen%C3%A7a-Educacional-2ea44f?style=for-the-badge)](#-aviso-legal)

<sub>⚡ 8 abas · 🎯 Aimbot & Silent Aim · 🛡️ Anti-Kick/Ban · 🚀 Fly, NoClip, Speed · 👁️ ESP · 🌐 Server Hop</sub>

</div>

---

<div align="center">

### 📑 Índice

[Sobre](#-sobre) ·
[Recursos](#-recursos) ·
[Como Usar](#-como-usar) ·
[Compatibilidade](#-compatibilidade) ·
[Atalhos](#-atalhos) ·
[Aviso Legal](#-aviso-legal)

</div>

---

## 📖 Sobre

O **DarkHUB Universal** é um script completo para Roblox que reúne, em uma única interface limpa e moderna, as ferramentas mais usadas no dia a dia: movimentação, visuais (ESP), combate, proteções anti-cheat, utilitários e ferramentas externas.

A interface usa a biblioteca **Fluent**, com tema escuro (`Darker`), notificações integradas e sistema de configurações salvas.

```
🌑 DarkHUB
   └─ Universal Script
      ├─ 👤 Player      ├─ ⚔️ Combat     ├─ 📦 External
      ├─ 🏃 Movement    ├─ 🌀 Fling      └─ ⚙️ Settings
      ├─ 👁️ Visuals     ├─ 🛡️ Bypass
```

---

## ✨ Recursos

<table>
<tr>
<td width="50%" valign="top">

### 👤 Player
- Teleporte para outro jogador
- Spectate / espionar jogador
- Lista de jogadores em tempo real

### 🏃 Movement
- **Speed Hack** (16–300)
- **NoClip** — atravessar paredes
- **Fly** & **Vehicle Fly** (velocidade ajustável)
- **Infinity Jump** & **Levitation**
- **Click TP** — teleporte por clique
- **TP to Spawn**
- **Waypoints** — salvar / teleportar / deletar
- **Anti-AFK**

### 👁️ Visuals
- **ESP** com Team Check
- Name Tags & Health Bar
- Cor do ESP personalizável
- **Fullbright** · **No Fog** · **Remove Effects**

</td>
<td width="50%" valign="top">

### ⚔️ Combat
- **Aimbot** — FOV, suavização, parte-alvo, wall check
- Círculo de FOV visível
- **Silent Aim** (requer metamétodos)
- **Triggerbot** com delay configurável
- Team Check em todas as opções

### 🌀 Fling
- Fling em alvo selecionado
- **Touch Fling** & **Fling All**
- **Anti-Fling** (proteção)

### 🛡️ Bypass
- **Anti-Kick & Ban**
- **Remote Report Block**
- **Anti-Cheat Breaker / Monitor / Scan**
- **Fingerprint Wipe**
- Destruir remotes de kick/ban
- **Lag Switch**

### 📦 External
- Infinity Yield · Dex Explorer · SimpleSpy

</td>
</tr>
</table>

### ⚙️ Settings
Stats (Ping / FPS) · Server Info · **Rejoin** · **Server Hop** · Sistema de configurações salvas (via Fluent `InterfaceManager`).

---

## 🚀 Como Usar

1. Abra seu executor de scripts favorito.
2. Cole o **loadstring** abaixo no editor.
3. Execute dentro de qualquer jogo do Roblox.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU-USUARIO/SEU-REPO/main/DarkHUB.lua"))()
```

> 💡 Substitua `SEU-USUARIO/SEU-REPO` pelo caminho real do seu repositório no GitHub.

---

## 🧩 Compatibilidade

| Recurso | Requisito |
|--------|-----------|
| UI / funções básicas | Qualquer executor com `HttpGet` |
| Silent Aim · Anti-Kick/Ban · Remote Block | Executor com suporte a **metamétodos** (`hookmetamethod`, `getrawmetatable`) |
| Proteção de GUI | `syn.protect_gui` / `gethui` (opcional) |
| Requisições externas | `syn.request` / `http.request` / `request` (com fallback para `HttpGet`) |

> O script detecta automaticamente os recursos disponíveis e notifica quando um executor não tem suporte a determinada função.

---

## ⌨️ Atalhos

| Tecla | Ação |
|-------|------|
| `Right Ctrl` | Minimizar / restaurar a interface |
| `E` (segurar) | Aim Key do Aimbot (padrão) |

---

## ⚠️ Aviso Legal

> [!WARNING]
> Este projeto é fornecido **apenas para fins educacionais e de estudo** sobre engenharia de UI e scripting em Lua.
>
> - O uso de scripts de terceiros pode violar os **Termos de Serviço do Roblox** e resultar em banimento da conta.
> - Os scripts da aba **External** são carregados via `HttpGet` de fontes de terceiros — use por sua conta e risco.
> - O autor **não se responsabiliza** por qualquer uso indevido, banimentos ou danos decorrentes do uso deste software.
>
> **Use com responsabilidade.**

---

<div align="center">

Feito com 🌑 e Lua · Interface por [Fluent](https://github.com/dawid-scripts/Fluent)

⭐ Se este projeto te ajudou, deixe uma estrela no repositório!

</div>
