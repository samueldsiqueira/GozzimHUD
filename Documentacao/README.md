# Documentação Base - Scripts ZeroBot (SamuhellHUD)

Esta pasta foi criada para documentar e explicar o funcionamento de cada script `.lua.script` localizados na pasta `SamuhellScripts`. Esses scripts são projetados para uso no **ZeroBot**, adicionando funcionalidades utilitárias, automações de combate e interfaces personalizadas (HUD).

Abaixo você encontra a explicação detalhada do foco e funcionamento de cada script:

## Interfaces e Informações (HUD)
* **char_info.lua.script**: Cria um painel de interface (HUD) na tela do jogo exibindo informações em tempo real do seu personagem (provavelmente vida, mana, experiência ou outros rastreadores).
* **fps_latency.lua.script**: Exibe taxa de quadros (FPS) e a latência (Ping) continuamente no canto superior esquerdo da tela. A latência é colorida dinamicamente dependendo da qualidade da conexão.
* **toggle_effects.lua.script**: Script que funciona como um botão no HUD associado a uma hotkey para ativar/desativar rapidamente os efeitos mágicos do cliente. Útil para melhorar o FPS durante combates ou pelegos.

## Utilitários e Automações Gerais (PvE / Caça)
* **autohaste.lua.script**: Botão na interface para ativar a magia de corrida (Haste). Ele detecta a vocação do personagem (Knight/Paladin vs Sorcerer/Druid) para conjurar a magia correta (*utani hur*, *utani gran hur* etc) e pausa automaticamente quando você entra em áreas de proteção (PZ).
* **autoloot.lua.script**: Cria um botão interativo (ícone de uma bag) para alternar o status do Auto-Loot. Esse saque é do tipo orientado por eventos (quando você ou o grupo mata o monstro, ele tenta coletar o loot).
* **doors.lua.script**: Automação que tenta abrir portas à sua frente automaticamente mesclando atalhos de teclado e repetições para garantir uma passagem fluida sem travar o personagem na porta.
* **eat.lua.script**: Alimentação automática. Um botão no HUD que consome a comida disponível na sua backpack em intervalos definidos visando manter a regeneração de mana/vida. Pausa automaticamente em Protection Zones.
* **fishing.lua.script**: Sistema que utiliza sua vara de pesca de forma autônoma. Também altera uma mensagem de texto exibindo quantas minhocas restam dependendo se o bot houver detectado o script ativado.
* **skinner.lua.script**: Ao ativar este botão de HUD, o bot irá tentar esfolar os corpos de monstros próximos usando as ferramentas específicas (*Obsidian Knife* ou *Blessed Wooden Stake*).
* **training.lua.script**: Feito para realizar treinos AFK (geralmente usando *Training Weapons* ou estátuas especiais). O script interrompe e envia notificações se sua arma de treino sumir / terminar as cargas.

## Combate, Curas e PvP
* **anti_push.lua.script**: Ícone clicável no HUD para ligar/desligar de forma ágil o sistema "Anti-Push" do bot. (Joga ouro e itens variados sob o seu personagem para evitar ser puxado/empurrado).
* **auto_ssa_might.lua.script**: Conjunto de ícones clicáveis no HUD que permitem controlar a equipagem automática de anéis e amuletos de defesa (Stone Skin Amulet e Might Ring). Essencial para segurar altos montantes de dano.
* **autoshoot.lua.script**: Interface vinculada à configuração no bot de "Rune Max". Dispara a runa alvo dependendo de como está configurado.
* **exiva.lua.script**: Uma versão melhorada da magia "Exiva" (Find Person). Segue o último alvo (sticky target) e conta com dois modos interessantes (Smart ou Frenzy).
* **holdtarget.lua.script**: Botão visual para alternar o uso do "Hold Target", função no PvP onde o bot nunca perde o lock do inimigo caso ele desapareça momentaneamente indo para outro andar ou correndo para fora da tela.
* **rage.lua.script**: Automação de feitiços de dano (Voltado especificamente para o feitiço *Utito Tempo* dos Knights). Analisa se é um momento seguro (ou eficiente) contando se há um mínimo de monstros na tela (ex: 2+) antes de gastar e usar a magia.
* **shootmwall.lua.script**: Script com hotkey associada para mirar Magic Walls de modo mais rápido, acompanhado por um ícone informático no HUD.

## Automakers Específicos de Mecânicas (Bosses)
* **oberon.lua.script**: Sistema de *Auto-Resposta* formulado para o chefão **Grand Master Oberon**. Este script lê o *Local Chat* em busca de falas da mecânica do Boss e reage enviando no chat público ou local a resposta oposta correta exigida pela mecânica, evitando a necessidade de ler e digitar as respostas manualmente para tornar o Boss vulnerável a dano.

---

### Como e onde modificar
Se você precisar alterar posições de ícones (X, Y na tela), IDs de itens preferenciais ou hotkeys, essas variáveis ficam nas primeiras linhas (*CONFIGURATION*) dentro de cada arquivo `.lua.script` correspondente e que você pode editar num simples Bloco de Notas ou VS Code.
