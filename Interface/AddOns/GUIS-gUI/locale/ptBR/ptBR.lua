local L = LibStub("gLocale-1.0"):NewLocale((select(1, ...)), "ptBR")
if not L then return end

--------------------------------------------------------------------------------------------------
--		Modules
--------------------------------------------------------------------------------------------------
-- ActionBars
do
	L["Layout '%s' doesn't exist, valid values are %s."] = "O leiaute '%s' não existe, valores válidos %s."
	L["There is a problem with your ActionBars.|nThe user interface needs to be reloaded in order to fix it.|nReload now?"] = "Há um problema com suas Barras de Ação.|nA interface de usuário tem de ser recarregada a fim de corrigir isso.|nRecarregar agora?"
	L["<Left-Click> to show additional ActionBars"] = "<Clique-Esquerdo> para exibir Barras de Ação adicionais"
	L["<Left-Click> to hide this ActionBar"] = "<Clique-Esquerdo> para esconder esta Barra de Ação"
end

-- ActionBars: micromenu
do
	L["Achievements"] = "Conquistas"
	L["Character Info"] = "Informações do Personagem"
	L["Customer Support"] = "Atendimento ao Cliente"
	L["Dungeon Finder"] = "Localizador de Masmorras"
	L["Dungeon Journal"] = "Almanaque de Masmorras"
	L["Game Menu"] = "Menu do Jogo"
	L["Guild"] = "Guilda"
	L["Guild Finder"] = "Localizador de Guildas"
	L["You're not currently a member of a Guild"] = "Você atualmente não é membro de uma guilda"
	L["Player vs Player"] = "Jogador x Jogador"
	L["Quest Log"] = "Registro de Missões"
	L["Raid"] = "Raide"
	L["Spellbook & Abilities"] = "Grimório e Habilidades"
	L["Starter Edition accounts cannot perform that action"] = "Contas Starter Edition não podem realizar esta ação"
	L["Talents"] = "Talentos"
	L["This feature becomes available once you earn a Talent Point."] = "Este recurso estará disponível assim que você ganhar um Ponto de Talento"
end

-- ActionBars: menu
do
	L["ActionBars are banks of hotkeys that allow you to quickly access abilities and inventory items. Here you can activate additional ActionBars and control their behaviors."] = "Barras de Ação são bancos de atalhos que permitem a você acessar rapidamente habilidades e itens do inventário. Aqui você pode ativar Barras de Ação adicionais e controlar seus comportamentos."
	L["Secure Ability Toggle"] = "Ativar/Desativar Habilidade Segura"
	L["When selected you will be protected from toggling your abilities off if accidently hitting the button more than once in a short period of time."] = "Quando selecionado você estará protegido de desativar suas habilidades se acidentalmente clicar no botão mais de uma vez em um curto período de tempo."
	L["Lock ActionBars"] = "Travar Barras de Ação"
	L["Prevents the user from picking up/dragging spells on the action bar. This function can be bound to a function key in the keybindings interface."] = "Previne o usuário de pegar/arrastar feitiços da barrão de ação. Esta função pode ser vinculada a uma tecla de função na interface de atalhos do teclado."
	L["Pick Up Action Key"] = "Tecla de Movimentação"
	L["ALT key"] = "Tecla ALT"
	L["Use the \"ALT\" key to pick up/drag spells from locked actionbars."] = "Utiliza a tecla\"ALT\" para pegar/arrastar feitiços de barras de ação travadas."
	L["CTRL key"] = "Tecla CTRL"
	L["Use the \"CTRL\" key to pick up/drag spells from locked actionbars."] = "Utiliza a tecla\"CTRL\" para pegar/arrastar feitiços de barras de ação travadas."
	L["SHIFT key"] = "Tecla SHIFT"
	L["Use the \"SHIFT\" key to pick up/drag spells from locked actionbars."] = "Utiliza a tecla\"SHIFT\" para pegar/arrastar feitiços de barras de ação travadas."
	L["None"] = "Nenhuma"
	L["No key set."] = "Nenhuma tecla definida"
	L["Visible ActionBars"] = "Barras de Ação Visíveis"
	L["Show the rightmost side ActionBar"] = "Exibir a Barra de Ação mais à direita"
	L["Show the leftmost side ActionBar"] = "Exibir a Barra de Ação mais à esquerda"
	L["Show the secondary ActionBar"] = "Exibir a segunda Barra de Ação"
	L["Show the third ActionBar"] = "Exibir a terceira Barra de Ação"
	L["Show the Pet ActionBar"] = "Exibir a Barra de Ação do Ajudante"
	L["Show the Shapeshift/Stance/Aspect Bar"] = "Exibir a Barra de Metamorfose/Postura/Aspecto"
	L["Show the Totem Bar"] = "Exibir a Barra de Totem"
	L["Show the Micro Menu"] = "Exibir o Micro Menu"
	L["ActionBar Layout"] = "Leiaute da Barra de Ação."
	L["Sort ActionBars from top to bottom"] = "Ordenar Barras de Ação de cima para baixo"
	L["This displays the main ActionBar on top, and is the default behavior of the UI. Disable to display the main ActionBar at the bottom."] = "Isto mostra a Barra de Ação principal no topo, e é o comportamento padrão da IU. Desative para mostrar a Barra de Ação principal na base."
	L["Button Size"] = "Tamanho do Botão"
	L["Choose the size of the buttons in your ActionBars"] = "Escolha o tamanho dos botões nas suas Barras de Ação"
	L["Sets the size of the buttons in your ActionBars. Does not apply to the TotemBar."] = "Define o tamanho dos botões nas suas Barras de Ação. Não se aplica à Barra de Totem."
end

-- ActionBars: Install
do
	L["Select Visible ActionBars"] = "Selecione as Barras de Ação Visíveis"
	L["Here you can decide what actionbars to have visible. Most actionbars can also be toggled by clicking the arrows located next to their edges which become visible when hovering over them with the mouse cursor. This does not work while engaged in combat."] = "Aqui você pode decidir quais barras de ação deixar visíveis. A maioria das barras de ação podem ser desativadas clicando nas setas localizadas próximas aos seus cantos que se tornam visíveis quando passando o cursor do mouse sobre elas. Isto não funciona quando em combate."
	L["You can try out different layouts before proceding!"] = "Você pode testar diferentes leiautes antes de proceder!"

	L["Toggle Bar 2"] = "Barra 2"
	L["Toggle Bar 3"] = "Barra 3"
	L["Toggle Bar 4"] = "Barra 4"
	L["Toggle Bar 5"] = "Barra 5"
	L["Toggle Pet Bar"] = "Barra do Ajudante"
	L["Toggle Shapeshift/Stance/Aspect Bar"] = "Barra de Metamorfose/Postura/Aspecto"
	L["Toggle Totem Bar"] = "Barra de Totem"
	L["Toggle Micro Menu"] = "Micro Menu"
	
	L["Select Main ActionBar Position"] = "Selecione a Posição da BArra de Ação Principal"
	L["When having multiple actionbars visible, do you prefer to have the main actionbar displayed at the top or at the bottom? The default setting is top."] = "Quando possuir múltiplas barras de ação visíveis, você prefere que a barra de ação principal seja exibida no topo ou na base? A definição padrão é no topo."
end

-- ActionButtons: Keybinds (displayed on buttons)
do
	L["A"] = true -- Alt
	L["C"] = true -- Ctrl
	L["S"] = true -- Shift
	L["M"] = true -- Mouse Button
	L["M3"] = true -- Middle/Third Mouse Button
	L["N"] = true -- Numpad
	L["NL"] = true -- Numlock
	L["CL"] = true -- Capslock
	L["Clr"] = true -- Clear
	L["Del"] = true -- Delete
	L["End"] = true -- End
	L["Home"] = true -- Home
	L["Ins"] = true -- Insert
	L["Tab"] = true -- Tab
	L["Bs"] = true -- Backspace
	L["WD"] = "RC" -- Mouse Wheel Down
	L["WU"] = "RB" -- Mouse Wheel Up
	L["PD"] = true -- Page Down
	L["PU"] = true -- Page Up
	L["SL"] = true -- Scroll Lock
	L["Spc"] = true -- Spacebar
	L["Dn"] = "Bai" -- Down Arrow
	L["Lt"] = "Esq" -- Left Arrow
	L["Rt"] = "Dir" -- Right Arrow
	L["Up"] = "Cim" -- Up Arrow
end

-- ActionButtons: menu
do
	L["ActionButtons are buttons allowing you to use items, cast spells or run a macro with a single keypress or mouseclick. Here you can decide upon the styling and visible elements of your ActionButtons."] = "Botões de Ação são botões que permitem a você utilizar itens, lançar feitiços ou rodar uma macro com uma única tecla ou clique de mouse. Aqui você pode decidir o estilo e os elementos visíveis de seus Botões de Ação."
	L["Button Styling"] = "Estilo do Botão"
	L["Button Text"] = "Texto do Botão"
	L["Show hotkeys on the ActionButtons"] = "Exibir atalhos nos Botões de Ação"
	L["Show Keybinds"] = "Exibir Teclas de Atalho"
	L["This will display your currently assigned hotkeys on the ActionButtons"] = "Isto irá exibir suas teclas de atalho vinculadas atualmente nos seus Botões de Ação"
	L["Show macro names on the ActionButtons"] = "Exibir nomes de macros nos Botões de Ação"
	L["Show Names"] = "Exibir Nomes"
	L["This will display the names of your macros on the ActionButtons"] = "Isto irá exibir os nomes de suas macros nos Botões de Ação"
	L["Show gloss layer on ActionButtons"] = "Exibir camada brilhante nos Botões de Ação"
	L["Show Gloss"] = "Exibir Brilho"
	L["This will display the gloss overlay on the ActionButtons"] = "Isto irá exibir a camada brilhante nos Botões de Ação"
	L["Show shade layer on ActionButtons"] = "Exibir camada de sombra nos Botões de Ação"
	L["This will display the shade overlay on the ActionButtons"] = "Isto irá exibir uma camada de sombra nos Botões de Ação"
	L["Show Shade"] = "Exibir Sombra"
	--L["Set amount of gloss"] = true
	--L["Set amount of shade"] = true
end

-- Auras: menu
do
	L["These options allow you to control how buffs and debuffs are displayed. If you wish to change the position of the buffs and debuffs, you can unlock them for movement with |cFF4488FF/glock|r."] = "Estas opções permitem que você controle como bônus e penalidades são exibidos. Se deseja mudar a posição dos bônus e penalidades, você pode destravá-los para o movimento com |cFF4488FF/glock|r."
	L["Aura Styling"] = "Estilo de Aura"
	L["Show gloss layer on Auras"] = "Exibir camada brilhante nas Auras"
	L["Show Gloss"] = "Exibir Brilho"
	L["This will display the gloss overlay on the Auras"] = "Isto irá exibir a camada brilhante nas Auras"
	L["Show shade layer on Auras"] = "Exibir camada de sombra nas Auras"
	L["This will display the shade overlay on the Auras"] = "Isto irá exibir uma camada de sombra nas Auras"
	L["Show Shade"] = "Exibir Sombra"
	L["Time Display"] = "Exibição de Tempo"
	L["Show remaining time on Auras"] = "Exibir o tempo restante nas Auras"
	L["Show Time"] = "Exibir Tempo"
	L["This will display the currently remaining time on Auras where applicable"] = "Isto irá exibir o tempo restante atual nas Auras, quando aplicável"
	L["Show cooldown spirals on Auras"] = "Exibir espirais de recarga em Auras"
	L["Show Cooldown Spirals"] = "Exibir Espirais de Recarga"
	L["This will display cooldown spirals on Auras to indicate remaining time"] = "Isto irá exibir espirais de tempo de recarga nas Auras para indicar o tempo restante"
end

-- Bags
do
	L["Gizmos"] = "Geringonças" -- used for "special" things like the toy train set
	L["Equipment Sets"] = "Conjuntos de Equipamentos" -- used for the stored equipment sets
	L["New Items"] = "Itens Novos" -- used for the unsorted new items category in the bags
	L["Click to sort"] = "Clique para ordenar"
	L["<Left-Click to toggle display of the Bag Bar>"] = "<Clique-Esquerdo para exibir a Barra de Mochilas>"
	L["<Left-Click to open the currency frame>"] = "<Clique-Esquerdo para abrir o quadro de moeda>"
	L["<Left-Click to open the category selection menu>"] = "<Clique-Esquerdo para abrir o menu de seleção de categoria>"
	L["<Left-Click to search for items in your bags>"] = "<Clique-Esquerdo para buscar por itens nas suas bolsas>"
	L["Close all your bags"] = "Fechar todos as suas bolsas"
	L["Close this category and keep it hidden"] = "Fechar esta categoria e a manter escondida"
	L["Close this category and show its contents in the main container"] = "Fechar esta categoria e exibir seu conteúdo no contêiner principal"
end

-- Bags: menus 
do
	L["A character can store items in its backpack, bags and bank. Here you can configure the appearance and behavior of these."] = "Um personagem pode guardar itens na sua mochila, bolsas e banco. Aqui você pode configurar a aparência e o comportamento destes."
	L["Container Display"] = "Exibição de Contêiner"
	L["Show this category and its contents"] = "Esibir esta categoria e seus contêiners"
	L["Hide this category and all its contents completely"] = "Esconder esta categoria e seu conteúdo completamente"
	L["Bypass"] = "Ignorar"
	L["Hide this category, and display its contents in the main container instead"] = "Esconde esta categoria, e em vez disso exibe seu conteúdo no contêiner principal"
	L["Choose the minimum item quality to display in this category"] = "Esolher a qualidade mínima do item para ser exibido nesta categoria"
	L["Bag Width"] = "Largura do Saco"
	L["Sets the number of horizontal slots in the bag containers. Does not apply to the bank."] = "Define o número de espaços horizontais nos contêiners de bolsas. Não se aplica ao banco."
	L["Bag Scale"] = "Escala do Saco"
	L["Sets the overall scale of the bags"] = "Define a escala geral das bolsas"
	L["Restack"] = "Reempilhar"
	L["Automatically restack items when opening your bags or the bank"] = "Reempilhar automaticamente os itens ao abrir suas bolsas ou o banco"
	L["Automatically restack when looting or crafting items"] = "Reempilhar automaticamente ao saquear ou forjar itens"
	L["Sorting"] = "Ordenação"
	L["Sort the items within each container"] = "Ordenar os itens dentro de cada contêiner"
	L["Sorts the items inside each container according to rarity, item level, name and quanity. Disable to have the items remain in place."] = "Ordena os itens dentro de cada contêiner de acordo com raridade, nível do item, nome e qualidade. Desative para que os itens mantenham seus lugares."
	L["Compress empty bag slots"] = "Comprimir espaços de bolsas vazios"
	L["Compress empty slots down to maximum one row of each type."] = "Comprimir espaços vazios até o máximo de uma linha de cada tipo."
	L["Lock the bags into place"] = "Travar as bolsas no lugar"
	L["Slot Button Size"] = "Tamanho do Botão de Espaço"
	L["Choose the size of the slot buttons in your bags."] = "Esolher o tamanho dos botões de espaço nas suas bolsas."
	L["Sets the size of the slot buttons in your bags. Does not affect the overall scale."] = "Define o tamanho dos botões de espaço nas suas bolsas. Não afeta a escala geral."
	L["Bag scale"] = "Escala do Saco"
	L["Button Styling"] = "Estilo do Botão"
	L["Show gloss layer on buttons"] = "Exibir camada brilhante nos botões"
	L["Show Gloss"] = "Exibir Brilho"
	L["This will display the gloss overlay on the buttons"] = "Isto irá exibir a camada brilhante nos botões"
	L["Show shade layer on buttons"] = "Exibir camada de sombra nos botões"
	L["This will display the shade overlay on the buttons"] = "Isto irá exibir uma camada de sombra nos botões"
	L["Show Shade"] = "Exibir Sombra"
	L["Show Durability"] = "Exibir Durabilidade"
	L["This will display durability on damaged items in your bags"] = "Isto irá exibir a durabilidade em itens danificados nas suas bolsas"
	L["Color unequippable items red"] = "Colorir itens não equipáveis de vermelho"
	L["This will color equippable items in your bags that you are unable to equip red"] = "Isto irá colorir itens equipáveis nas suas bolsas que você é incapaz de equipar de vermelho"
	L["Apply 'All In One' Layout"] = "Aplicar Leiaute 'Tudo Em Um'"
	L["Click here to automatically configure the bags and bank to be displayed as large unsorted containers."] = "Clique aqui para configurar automaticamente as bolsas e o banco para serem exibidos como contêineres grandes e desordenados."
	L["The bags can be configured to work as one large 'all-in-one' container, with no categories, no sorting and no empty space compression. If you wish to have that type of layout, click the button:"] = "As bolsas podem ser configurados para trabalhar como um grande contêiner 'tudo em um', sem categorias, ordenação e nenhuma compressão de espaços vazios. Se deseja ter este tipo de leiaute, clique no botão:"
	L["The 'New Items' category will display newly acquired items if enabled. Here you can set which categories and rarities to include."] = "A categoria 'Itens Novos'exibirá novos itens adquiridos se ativada. Aqui você pode definir quais categorias e raridades incluir."
	L["Minimum item quality"] = "Qualidade mínima de item"
	L["Choose the minimum item rarity to be included in the 'New Items' category."] = "Escolher a raridade mínima de item a ser incluída na categoria 'Novos Itens'."
end

-- Bags: Install
do
	L["Select Layout"] = "Selecionar Leiaute"
	L["The %s bag module has a variety of configuration options for display, layout and sorting."] = "O módulo de saco %s possui uma variedade de opções de configuração para exibição, leiaute e ordenação."
	L["The two most popular has proven to be %s's default layout, and the 'All In One' layout."] = "Os dois mais populares provaram ser o leiaute padrão do %s, e o leiaute 'Tudo Em Um'."
	L["The 'All In One' layout features all your bags and bank displayed as singular large containers, with no categories, no sorting and no empty space compression. This is the layout for those that prefer to sort and control things themselves."] = "O leiaute 'Tudo Em Um' faz com que todas as suas bolsas e o banco sejam exibidos como grandes únicos contêineres, sem categorias, ordenação, e nenhuma compressão de espaços vazios. Este é o leiaute para aqueles que preferem ordenar e controlar as coisas por eles mesmos."
	L["%s's layout features the opposite, with all categories split into separate containers, and sorted within those containers by rarity, item level, stack size and item name. This layout also compresses empty slots to take up less screen space."] = "O leiaute do %s faz o oposto, com todas as categorias divididas em contêineres separados, e ordenados internamente por raridade, nível do item, tamanho da pilha e nome do item. Este leiaute comprime espaços vazios para tomar menos espaço da tela."
	L["You can open your bags to test out the different layouts before proceding!"] = "Você pode abrir suas bolsas para testar os diferentes leiautes antes de prosseguir!"
	L["Apply %s's Layout"] = "Aplicar o Leiaute do %s"
end

-- Bags: chat commands
do
	L["Empty bag slots will now be compressed"] = "Os epaços vazios das bolsas serão comprimidos"
	L["Empty bag slots will no longer be compressed"] = "Os espaços vazios das bolsas não serão mais comprimidos"
end

-- Bags: restack
do
	L["Restack is already running, use |cFF4488FF/restackbags resume|r if stuck"] = "A reempilhagem já está em andamento, utilize |cFF4488FF/restackbags resume|r se travado"
	L["Resuming restack operation"] = "Continuando a operação de reempilhagem"
	L["No running restack operation to resume"] = "Nenhuma operação de reempilhagem para continuar"
	L["<Left-Click to restack the items in your bags>"] = "<Clique-Esquerdo para reempilhar os itens nas suas bolsas>"
	L["<Left-Click to restack the items in your bags>|n<Right-Click for options>"] = "<Clique-Esquerdo para reempilhar os itens nas suas bolsas>|n<Clique-Direito para opções>"
end

-- Castbars: menu
do
	L["Here you can change the size and visibility of the on-screen castbars. If you wish to change their position, you can unlock them for movement with |cFF4488FF/glock|r."] = "Aqui você pode alterar o tamanho e a visibilidade das barras de lançamento na tela. Se você deseja alterar suas posições, você pode destravá-las para movimentação com |cFF4488FF/glock|r."
	L["Show the player castbar"] = "Exibir a barra de lançamento do jogador"
	L["Show for tradeskills"] = "Exibir para habilidades de troca"
	L["Show the pet castbar"] = "Exibir a barra de lançamento do ajudante"
	L["Show the target castbar"] = "Exibir a barra de lançamento do alvo"
	L["Show the focus target castbar"] = "Exibir a barra de lançamento do foco do alvo"
	L["Set Width"] = "Definir Largura"
	L["Set the width of the bar"] = "Define a largura da barra"
	L["Set Height"] = "Definir Altura"
	L["Set the height of the bar"] = "Define a altura da barra"
end

-- Chat: timestamp settings tooltip (http://www.lua.org/pil/22.1.html)
do
	L["|cFFFFD100%a|r abbreviated weekday name (e.g., Wed)"] = "|cFFFFD100%a|r nome do dia da semana abreviado (ex: Qua)"
	L["|cFFFFD100%A|r full weekday name (e.g., Wednesday)"] = "|cFFFFD100%A|r nome do dia da semana completo (ex: Quarta-feira)"
	L["|cFFFFD100%b|r abbreviated month name (e.g., Sep)"] = "|cFFFFD100%b|r nome do mês abreviado (ex: Set)"
	L["|cFFFFD100%B|r full month name (e.g., September)"] = "|cFFFFD100%B|r nome do mês completo (ex: Setembro)"
	L["|cFFFFD100%c|r date and time (e.g., 09/16/98 23:48:10)"] = "|cFFFFD100%c|r data e hora (ex: 16/09/98 23:48:10)"
	L["|cFFFFD100%d|r day of the month (16) [01-31]"] = "|cFFFFD100%d|r dia do mês (16) [01-31]"
	L["|cFFFFD100%H|r hour, using a 24-hour clock (23) [00-23]"] = "|cFFFFD100%H|r hora, utilizando o formato de 24-horas (23) [00-23]"
	L["|cFFFFD100%I|r hour, using a 12-hour clock (11) [01-12]"] = "|cFFFFD100%I|r hora, utilizando o formato de 12-horas (11) [01-12]"
	L["|cFFFFD100%M|r minute (48) [00-59]"] = "|cFFFFD100%M|r minuto (48) [00-59]"
	L["|cFFFFD100%m|r month (09) [01-12]"] = "|cFFFFD100%m|r mês (09) [01-12]"
	L["|cFFFFD100%p|r either 'am' or 'pm'"] = "|cFFFFD100%p|r ou 'am' ou 'pm'"
	L["|cFFFFD100%S|r second (10) [00-61]"] = "|cFFFFD100%S|r segundo (10) [00-61]"
	L["|cFFFFD100%w|r weekday (3) [0-6 = Sunday-Saturday]"] = "|cFFFFD100%w|r dia da semana (3) [0-6 = Domingo-Sábado]"
	L["|cFFFFD100%x|r date (e.g., 09/16/98)"] = "|cFFFFD100%x|r data (ex: 16/09/98)"
	L["|cFFFFD100%X|r time (e.g., 23:48:10)"] = "|cFFFFD100%X|r hora (ex: 23:48:10)"
	L["|cFFFFD100%Y|r full year (1998)"] = "|cFFFFD100%Y|r ano completo (1998)"
	L["|cFFFFD100%y|r two-digit year (98) [00-99]"] = "|cFFFFD100%y|r ano em dois-d[igitos (98) [00-99]"
	L["|cFFFFD100%%|r the character `%´"] = "|cFFFFD100%%|r o caractere `%´" -- 'character' here refers to a letter or number, not a game character...
end

-- Chat: names of the chat frames handled by the addon
do
	L["Main"] = "Principal"
	L["Loot"] = "Saque"
	L["Log"] = "Registro"
	L["Public"] = "Público"
end

-- Chat: abbreviated channel names
do
	L["G"] = "Gd" -- Guild
	L["O"] = "Of" -- Officer
	L["P"] = "Gp" -- Party
	L["PL"] = "LGp" -- Party Leader
	L["DG"] = "GM" -- Dungeon Guide
	L["R"] = "R" -- Raid
	L["RL"] = "LR" -- Raid Leader
	L["RW"] = "AR" -- Raid Warning
	L["BG"] = "CB" -- Battleground
	L["BGL"] = "LCB" -- Battleground Leader
	L["GM"] = "MJ" -- Game Master
end

-- Chat: various abbreviations
do
	L["Guild XP"] = "EXP da Guilda" -- Guild Experience
	L["HK"] = "MH" -- Honorable Kill
	L["XP"] = "EXP" -- Experience
end

-- Chat: menu
do
	L["Here you can change the settings of the chat windows and chat bubbles. |n|n|cFFFF0000If you wish to change visible chat channels and messages within a chat window, background color, font size, or the class coloring of character names, then Right-Click the chat tab located above the relevant chat window instead.|r"] = "Aqui você pode alterar as definições das janelas de bate-papo e bolhas de bate-papo. |n|n|cFFFF0000Se ao invés disso, você deseja alterra os canais e mensagens de bate-papo visíveis dentro de uma janela de bate-papo, a cor de fundo, o tamanho da fonte, ou a classe de coloração dos nomes de personagens, então Clique-Direito na aba de bate-papo localizada sobre a janela de bate-papo relevante.|r"
	L["Enable sound alerts when receiving whispers or private Battle.net messages."] = "Ativar alertas sonoros ao receber sussurros ou mensagens Battle.net privadas."

	L["Chat Display"] = "Exibição de Bate-Papo"
	L["Abbreviate channel names."] = "Abreviar nomes de canais."
	L["Abbreviate global strings for a cleaner chat."] = "Abreviar textos globais para um bate-papo mais limpo."
	L["Display brackets around player- and channel names."] = "Exibir colchetes em volta dos nomes de personagem e canais."
	L["Use emoticons in the chat"] = "Usar emoticons no bate-papo"
	L["Auto-align the text depending on the chat window's position."] = "Alinhar automaticamente o texto dependendo da posição da janela de bate-papo."
	L["Auto-align the main chat window to the bottom left panel/corner."] = "Alinhar automaticamenet a janela de bate-papo principal para o canto/painel inferior esquerdo."
	L["Auto-size the main chat window to match the bottom left panel size."] = "Redimensionar automaticamente a janela de bate-papo principal para combinar com o tamanho do painel inferior esquerdo."

	L["Timestamps"] = "Marcações de horário"
	L["Show timestamps."] = "Exibir marcações de horário."
	L["Timestamp color:"] = "Cor da marcação de horário:"
	L["Timestamp format:"] = "Formato da marcação de horário:"

	L["Chat Bubbles"] = "Bolhas de Bate-Papo"
	L["Collapse chat bubbles"] = "Recolher bolhas de bate-papo"
	L["Collapses the chat bubbles to preserve space, and expands them on mouseover."] = "Recolhe as bolhas de bate-papo para preservar espaço, e as expande ao passar do mouse."
	L["Display emoticons in the chat bubbles"] = "Exibir emoticons nas bolhas de bate-papo"

	L["Loot Window"] = "Janela de Saque"
	L["Create 'Loot' Window"] = "Criar Janela de 'Saque'"
	L["Enable the use of the special 'Loot' window."] = "Ativar o uso da janela de 'Saque' especial."
	L["Maintain the channels and groups of the 'Loot' window."] = "Manter os canais e grupos da janela de 'Saque'"
	L["Auto-align the 'Loot' chat window to the bottom right panel/corner."] = "Alinhar automaticamente a janela de bate-papo de 'Saque' para o canto/painel inferior direito."
	L["Auto-size the 'Loot' chat window to match the bottom right panel size."] = "Redimensionar automaticamente a janela de bate-papo de 'Saque' para combinar com o tamanho do painel inferior direito."
end

-- Chat: Install
do
	L["Public Chat Window"] = "Janela de Bate-Papo Pública"
	L["Public chat like Trade, General and LocalDefense can be displayed in a separate tab in the main chat window. This will keep your main chat window free from intrusive spam, while still having all the relevant public chat available. Do you wish to do so now?"] = "Bate-Papo público como Comércio, Geral e Defesa Local pode ser exibido numa aba separada na janela de bate-papo principal. Isto fará com que sua janela de bate-papo principal fique livre de propaganda intrusiva, mantendo ainda todo o bate-papo público relevante disponível. Você deseja fazer isso agora?"

	L["Loot Window"] = "Janela de Saque"
	L["Information like received loot, crafted items, experience, reputation and honor gains as well as all currencies and similar received items can be displayed in a separate chat window. Do you wish to do so now?"] = "Informações como saque recebido, itens forjados, experiência, reputação e ganhos de honra assim como todas as moedas e itens parecidos recebidos podem ser exibidos numa janela de bate-papo separada. Você deseja fazer isso agora?"
	
	L["Initial Window Size & Position"] = "Posição e Tamanho Inicial da Janela"
	L["Your chat windows can be configured to match the unitframes and the bottom UI panels in size and position. Do you wish to do so now?"] = "Suas janelas de bate-papo podem ser configuradas para combinar com os quadros de unidade e os painéis da base da IU em tamanho e posição. Deseja fazer isso agora?"
	L["This will also dock any additional chat windows."] = "Isto encaixará quaisquer janelas de bate-papo adicionais."
	
	L["Window Auto-Positioning"] = "Posicionamento Automático da Janela"
	L["Your chat windows will slightly change position when you change UI scale, game window size or screen resolution. The UI can maintain the position of the '%s' and '%s' chat windows whenever you log in, reload the UI or in any way change the size or scale of the visible area. Do you wish to activate this feature?"] = "Suas janelas de bate-papo mudarão um pouco de posição quando você alterar a escala da IU, o tamanho da janela do jogo ou a resolução de tela. A IU pode manter a posição das janelas de bate-papo '%s' e '%s' sempre que você se conectar, recarregar a IU ou de qualquer maneira alterar o tamanho ou a escala da área visível. Você deseja ativar este recurso?"
	
	L["Window Auto-Sizing"] = "Redimensionamento Automático da Janela"
	L["Would you like the UI to maintain the default size of the chat frames, aligning them in size to visually fit the unitframes and bottom UI panels?"] = "Você gostaria que a IU mantenha o tamanho padrão dos quadros de bate-papo, alinhando eles em tamanho para caber visualmente nos quadros de unidade e painels da base da IU?"
	
	L["Channel & Window Colors"] = "Cores de Janela e Canal"
	L["Would you like to change chatframe colors to what %s recommends?"] = "Você gostaria de alterar as cores do quadro de bate-papo para o que o %s recomenda?"
end

-- Combat
do
	L["dps"] = "dps" -- Damage Per Second
	L["hps"] = "cps" -- Healing Per Second
	L["tps"] = "aps" -- Threat Per Second
	L["Last fight lasted %s"] = "A última luta durou %s"
	L["You did an average of %s%s"] = "Você fez uma média de %s%s"
	L["You are overnuking!"] = "Você está explodindo!"
	L["You have aggro, stop attacking!"] = "Você possui aggro, pare de atacar!"
	L["You are tanking!"] = "Você está tanqueando!"
	L["You are losing threat!"] = "Você está perdendo ameaça!"
	L["You've lost the threat!"] = "Você perdeu a ameaça!"
end

-- Combat: menu
do
	L["Simple DPS/HPS Meter"] = "Medidor de DPS/CPS Simples"
	L["Enable simple DPS/HPS meter"] = "Ativa o medidor de DPS/CPS simples"
	L["Show DPS/HPS when you are solo"] = "Exibir DPS/CPS quando você está solo"
	L["Show DPS/HPS when you are in a PvP instance"] = "Exibir DPS/CPS quando você está em uma instância JxJ"
	L["Display a simple verbose report at the end of combat"] = "Exibir um relatório detalhado simples ao final do combate"
	L["Minimum DPS to display: "] = "DPS mínimo a ser exibido:"
	L["Minimum combat duration to display: "] = "Duração mínima de combate a ser exibida: "
	L["Simple Threat Meter"] = "Medidor de Ameaça Simples"
	L["Enable simple Threat meter"] = "Ativa o medidor de ameaça simples"
	L["Use the Focus target when it exists"] = "Utilizar o foco do alvo quando existir"
	L["Enable threat warnings"] = "Ativar avisos de ameaça"
	L["Show threat when you are solo"] = "Exibir ameaça quando você estiver solo"
	L["Show threat when you are in a PvP instance"] = "Exibir ameaça quando você estiver em uma instância JxJ"
	L["Show threat when you are a healer"] = "Exibir ameaça quando você for um curador"
	L["Enable simple scrolling combat text"] = "Ativar rolagem de texto de combate simples"
end

-- Combatlog
do
	L["GUIS"] = true -- the visible name of our custom combat log filter, used to identify it
	L["Show simplified messages of actions done by you and done to you."] = "Exibir mensagens simplificadas de ações realizadas por você e a você." -- the description of this filter
end

-- Combatlog: menu
do
	L["Maintain the settings of the GUIS filter so that they're always the same"] = "Manter as definições do filtro GUIS para que sejam sempre as mesmas"
	L["Keep only the GUIS and '%s' quickbuttons visible, with GUIS at the start"] = "Manter apenas os botões rápidos do GUIS e '%s' visíveis, com o GUIS no início"
	L["Autmatically switch to the GUIS filter when you log in or reload the UI"] = "Alterar automaticamente ao filtro do GUIS quando você conectar ou recarregar a IU"
	L["Autmatically switch to the GUIS filter whenever you see a loading screen"] = "Alterar automaticamente ao filtro do GUIS sempre que você ver uma tela de carregamento"
	L["Automatically switch to the GUIS filter when entering combat"] = "Alterar automaticamente ao filtro do GUIS quando entrar em combate"
end

-- Loot
do
	L["BoE"] = "VaE" -- Bind on Equip
	L["BoP"] = "VaS" -- Bind on Pickup
end

-- Merchant
do
	L["Selling Poor Quality items:"] = "Vendendo itens de Baixa Qualidade:"
	L["-%s|cFF00DDDDx%d|r %s"] = true -- nothing to localize in this one, unless you wish to change the formatting
	L["Earned %s"] = "Recebeu %s"
	L["You repaired your items for %s"] = "Você reparou seus itens por %s"
	L["You repaired your items for %s using Guild Bank funds"] = "Você reparou seus itens por %s utilizando fundos do Banco da Guilda"
	L["You haven't got enough available funds to repair!"] = "Você não possui fundos disponíveis suficientes para reparar!"
	L["Your profit is %s"] = "Seu lucro é de %s"
	L["Your expenses are %s"] = "Seus gastos são de %s"
	L["Poor Quality items will now be automatically sold when visiting a vendor"] = "Itens de Baixa Qualidade serão vendidos automaticamente ao se visitar um vendedor"
	L["Poor Quality items will no longer be automatically sold"] = "Itens de Baixa Qualidade não serão mais vendidos automaticamente"
	L["Your items will now be automatically repaired when visiting a vendor with repair capabilities"] = "Seus itens serão reparados automaticamente ao se visitar um vendedor com capacidade de reparar"
	L["Your items will no longer be automatically repaired"] = "Seus itens não serão mais reparados automaticamente"
	L["Your items will now be repaired using the Guild Bank if the options and the funds are available"] = "Seus itens serão reparados utilizando o Banco da Guilda se as opções e os fundos estiverem disponíveis"
	L["Your items will now be repaired using your own funds"] = "Seus itens serão reparados utilizando seus próprios fundos"
	L["Detailed reports for autoselling of Poor Quality items turned on"] = "Relatórios detalhados de venda automática de itens de Baixa Qualidade ligados"
	L["Detailed reports for autoselling of Poor Quality items turned off, only summary will be shown"] = "Relatórios detalhados de venda automática de itens de Baixa Qualidade desligados, apenas o sumário será exibido"
	L["Toggle autosell of Poor Quality items"] = "Ativar a venda automática de itens de Baixa Qualidade"
	L["Toggle display of detailed sales reports"] = "Ativar a exibição de relatórios de vendas detalhados"
	L["Toggle autorepair of your armor"] = "Ativar reparo automático de sua armadura"
	L["Toggle Guild Bank repairs"] = "Ativar reparos com o Banco da Guilda"
	L["<Alt-Click to buy the maximum amount>"] = "<Alt-Clique para comprar a quantia máxima>"
end


-- Merchant: Menu
do
	L["Here you can configure the options for automatic actions upon visiting a merchant, like selling junk and repairing your armor."] = "Aqui você pode configurar as opções para ações automáticas ao visitar um mercador, como vender sucata e reparar sua armadura."
	L["Automatically repair your armor and weapons"] = "Reparar automaticamente suas armaduras e armas"
	L["Enabling this option will show a detailed report of the automatically sold items in the default chat frame. Disabling it will restrict the report to gold earned, and the cost of repairs."] = "Ao ativar esta opção será exibido um raleótio detalhado de itens vendidos automaticamente no quadro padrão de bate-papo. Ao desativar o relatório será restrito ao ouro obtido, e custo dos reparos."
	L["Automatically sell poor quality items"] = "Vender automaticamente itens de baixa qualidade"
	L["Enabling this option will automatically sell poor quality items in your bags whenever you visit a merchant."] = "Ao ativar esta opção itens de baixa qualidade nas suas bolsas serão vendidos automaticamente sempre que você visitar um mercador."
	L["Show detailed sales reports"] = "Exibir relatórios de vendas detalhados"
	L["Enabling this option will automatically repair your items whenever you visit a merchant with repair capability, as long as you have sufficient funds to pay for the repairs."] = "Ao ativar esta opção seus itens serão reparados automaticamente sempre que voc~e visitar um mercador com capacidade de reparar, contanto que você possua fundos suficientes para pagar pelos reparos."
	L["Use your available Guild Bank funds to when available"] = "Utilizar seus fundos do Banco da Guilda quando disponíveis"
	L["Enabling this option will cause the automatic repair to be done using Guild funds if available."] = "Ao ativar esta opção os reparos automáticos serão efetuados utilizando os fundos da Guilda quando disponíveis."
end

-- Minimap
do
	L["Calendar"] = "Calendário"
	L["New Event!"] = "Novo Evento!"
	L["New Mail!"] = "Nova Mensagem!"
	
	L["Raid Finder"] = "Localizador de Raide"
	
	L["(Sanctuary)"] = "(Santuário)"
	L["(PvP Area)"] = "(Área JxJ)"
	L["(%s Territory)"] = "(Território da %s)"
	L["(Contested Territory)"] = "(Território Contestado)"
	L["(Combat Zone)"] = "(Zona de Combate)"
	L["Social"] = "Social"
end

-- Minimap: menu
do
	L["The Minimap is a miniature map of your closest surrounding areas, allowing you to easily navigate as well as quickly locate elements such as specific vendors, or a herb or ore you are tracking. If you wish to change the position of the Minimap, you can unlock it for movement with |cFF4488FF/glock|r."] = "O Minimapa é um mapa em miniatura das áreas próximas ao seu redor, permitindo a você navegar facilmente e também a localizar elementos como vendedores específicos, ou uma erva ou minério que você está rastreando. Se você deseja alterar a posição do Minimpara, você pode destravá-lo para movimento com |cFF4488FF/glock|r."
	L["Display the clock"] = "Exibir o relógio"
	L["Display the current player coordinates on the Minimap when available"] = "Exibir as coordenadas atuais do jogador no Minimapa quando disponíveis"
	L["Use the Mouse Wheel to zoom in and out"] = "Utilizar a Roda do Mouse para aumentar e diminuir o zoom"
	L["Display the difficulty of the current instance when hovering over the Minimap"] = "Exibir a dificuldade da instância atual quando passar o mouse sobre o Minimapa"
	L["Display the shortcut menu when clicking the middle mouse button on the Minimap"] = "Exibir o menu de atalhos quando clicar com o botão do meio do mouse no Minimapa"
	L["Rotate Minimap"] = "Rotacionar o Minimapa"
	L["Check this to rotate the entire minimap instead of the player arrow."] = "Marque isto para rotacionar o minimapa inteiro ao invés da seta do jogador."
end

-- Nameplates: menu
do
	L["Nameplates are small health- and castbars visible over a character or NPC's head. These options allow you to control which Nameplates are visible within the game field while you play."] = "Placas de Nomes são pequenas barras de lançamento e vida visíveis sobre a cabeça de um personagem ou PNJ. Estas opções permitem que você controle quais Placas de Nomes são visíveis no campo de jogo enquanto você joga."
	L["Automatically enable nameplates based on your current specialization"] = "Ativar automaticamente placas de nomes baseadas na sua especialização atual"
	L["Automatically enable friendly nameplates for repeatable quests that require them"] = "Ativar automaticamente placas de nomes de amigos para missões repetíveis que as necessitem"
	L["Only show friendly nameplates when engaged in combat"] = "Apenas exonor placas de nomes de amigos quando em combate"
	L["Only show enemy nameplates when engaged in combat"] = "Apenas exibir placas de nomes de inimigos em combate"
	L["Use a blacklist to filter out certain nameplates"] = "Utilizar uma lista negra para filtrar certas placas de nomes"
	L["Display character level"] = "Exibir nível do personagem"
	L["Hide for max level characters when you too are max level"] = "Esconder para personagens de nível máximo quando você também estiver no nível máximo"
	L["Display character names"] = "Exibir nome do personagem"
	L["Display combo points on your target"] = "Exibir pontos de combo no seu alvo"
	
	L["Nameplate Motion Type"] = "Tipo de Movimento da Placa de Nome"
	L["Overlapping Nameplates"] = "Sobreposição de Placas de Nomes"
	L["Stacking Nameplates"] = "Empilhamento de Placas de Nomes"
	L["Spreading Nameplates"] = "Espalhamento de Placas de Nomes"
	L["This method will allow nameplates to overlap."] = "Este método permitirá que placas de nomes se sobreponham."
	L["This method avoids overlapping nameplates by stacking them vertically."] = "Este método evitará a sobreposição de placas de nomes empilhando-as verticalmente."
	L["This method avoids overlapping nameplates by spreading them out horizontally and vertically."] = "Este método evitará a sobreposição de placas de nomes espalhando-as horizontalmente e verticalmente."
	
	L["Friendly Units"] = "Unidades Amigas"
	L["Friendly Players"] = "Jogadores Amigos"
	L["Turn this on to display Unit Nameplates for friendly units."] = "Ligue para exibir Placas de Nomes de Unidades para unidades amigas."
	L["Enemy Units"] = "Unidades Inimigas"
	L["Enemy Players"] = "Jogadores Inimigos"
	L["Turn this on to display Unit Nameplates for enemies."] = "Ligue para exibir Placas de Nomes de Unidades para inimigos."
	L["Pets"] = "Ajudantes"
	L["Turn this on to display Unit Nameplates for friendly pets."] = "Ligue para exibir Placas de Nomes de Unidades para ajudantes amigos."
	L["Turn this on to display Unit Nameplates for enemy pets."] = "Ligue para exibir Placas de Nomes de Unidades para ajudantes inimigos."
	L["Totems"] = "Totens"
	L["Turn this on to display Unit Nameplates for friendly totems."] = "Ligue para exibir Placas de Nomes de Unidades para totens amigos."
	L["Turn this on to display Unit Nameplates for enemy totems."] = "Ligue para exibir Placas de Nomes de Unidades para totens inimigos."
	L["Guardians"] = "Guardiões"
	L["Turn this on to display Unit Nameplates for friendly guardians."] = "Ligue para exibir Placas de Nomes de Unidades para guardiões amigos."
	L["Turn this on to display Unit Nameplates for enemy guardians."] = "Ligue para exibir Placas de Nomes de Unidades para guardiões inimigos."
end

-- Panels
do
	L["<Left-Click to open all bags>"] = "<Clique-Esquerdo para abrir todas as bolsas>"
	L["<Right-Click for options>"] = "<Clique-Direito para opções>"
	L["No Guild"] = "Nenhuma Guilda"
	L["New Mail!"] = "Nova Mensagem!"
	L["No Mail"] = "Nenhuma Mensagem"
	L["Total Usage"] = "Uso de Memória Total:"
	L["Tracked Currencies"] = "Moedas Acompanhadas"
	L["Additional AddOns"] = "AddOns Adicionais"
	L["Network Stats"] = "Estatísticas da Rede"
	L["World latency:"] = "Latência do mundo:"
	L["World latency %s:"] = "Latência do mundo %s:"
	L["(Combat, Casting, Professions, NPCs, etc)"] = "(Combate, Lançamento, Profissões, PNJs, etc)"
	L["Realm latency:"] = "Latência do reino:"
	L["Realm latency %s:"] = "Latência do reino %s:"
	L["(Chat, Auction House, etc)"] = "(Bate-Papo, Casa de Leilões, etc)"
	L["Display World Latency %s"] = "Exibir a Latência do Mundo %s"
	L["Display Home Latency %s"] = "Exibir a Latencia de Casa %s"
	L["Display Framerate"] = "Exibir Taxa de Quadros"

	L["Incoming bandwidth:"] = "Largura de banda de entrada:"
	L["Outgoing bandwidth:"] = "Largura de banda de saída:"
	L["KB/s"] = true
	L["<Left-Click for more>"] = "<Clique-Esquerdo para mais>"
	L["<Left-Click to toggle Friends pane>"] = "<Clique-Esquerdo para ativar o painel de Amigos>"
	L["<Left-Click to toggle Guild pane>"] = "<Clique-Esquerdo para ativar o painel da Guilda>"
	L["<Left-Click to toggle Reputation pane>"] = "<Clique-Esquerdo para ativar o painel de Reputação>"
	L["<Left-Click to toggle Currency frame>"] = "<Clique-Esquerdo para ativar o painel de Modea>"
	L["%d%% of normal experience gained from monsters."] = "%d%% da experiência normal recebida de monstros."
	L["You should rest at an Inn."] = "Você deve descansar numa Estalagem"
	L["Hide copper when you have at least %s"] = "Esconder o bronze quando você possuir ao menos %s"
	L["Hide silver and copper when you have at least %s"] = "Esconder a prata quando você possuir ao menos %s"
	L["Invite a member to the Guild"] = "Convidar um membro à Guilda"
	L["Change the Guild Message Of The Day"] = "Alterar a Mensagem do Dia Da Guilda"
	L["Select currencies to always watch:"] = "Selecionar moedas para se acompanhar sempre:"
	L["Select how your gold is displayed:"] = "Selecionar como o ouro será exibido:"
	
	L["No container equipped in slot %d"] = "Nenhum contêiner equipado no espaço %d"
end

-- Panels: menu
do
	L["UI Panels are special frames providing information about the game as well allowing you to easily change settings. Here you can configure the visibility and behavior of these panels. If you wish to change their positon, you can unlock them for movement with |cFF4488FF/glock|r."] = "Painéis de IU são quadros especiais que fornecem informações sobre o jogo e também permitem a você facilmente alterar as definições. Aqui você pode configurar a visibilidade e o comportamento desses painéis. Se deseja alterar suas positções, você pode destravá-los para movimento com |cFF4488FF/glock|r."
	L["Visible Panels"] = "Painéis Visíveis"
	L["Here you can decide which of the UI panels should be visible. They can still be moved with |cFF4488FF/glock|r when hidden."] = "Aqui você pode decidir quais painéis da IU devem estar visíveis. Elas ainda podem ser movidos com |cFF4488FF/glock|r quando escondidos."
	L["Show the bottom right UI panel"] = "Exibir o painel de IU da base direita"
	L["Show the bottom left UI panel"] = "Exibir o painel de IU da base esquerda"
	L["Bottom Right Panel"] = "Painel da Base Direita"
	L["Bottom Left Panel"] = "Painel da Base Esquerda"
end

-- Quest: menu
do
	L["QuestLog"] = "Registro de Missões"
	L["These options allow you to customize how game objectives like Quests and Achievements are displayed in the user interface. If you wish to change the position of the ObjectivesTracker, you can unlock it for movement with |cFF4488FF/glock|r."] = "Estas opções permitem a você personalizar como os objetivos do jogo como Missões e Conquistas são exibidos na interface de usuário. Se deseja alterar a posição do Acompanhador de Objetivos, você pode destravá-lo para movimento com |cFF4488FF/glock|r."
	L["Display quest level in the QuestLog"] = "Exibir o nível da missão no Registro de Missões"
	L["Objectives Tracker"] = "Acompanhador de Objetivos"
	L["Autocollapse the WatchFrame"] = "Reduzir automaticamente o Quadro de Observação"
	L["Autocollapse the WatchFrame when a boss unitframe is visible"] = "Reduzir automaticamente o Quadro de Observação quando um quadro de unidade de chefe está visível"
	L["Automatically align the WatchFrame based on its current position"] = "Alinhar automaticamente o Quadro de Observação baseadoo em sua posição atual"
	L["Align the WatchFrame to the right"] = "Alinhar o Quadro de Observação para a direita."
end

-- Tooltips
do
	L["Here you can change the settings for the game tooltips"] = "Aqui você pode alterar as definições das dicas do jogo"
	L["Hide while engaged in combat"] = "Esconder dicas quando em combate"
	L["Show values on the tooltip healthbar"] = "Exibir valores na barra de vida da dica"
	L["Show player titles in the tooltip"] = "Exibir os títulos do jogador na dica"
	L["Show player realms in the tooltip"] = "Exibir os reinos do jogador na dica"
	L["Positioning"] = "Posicionamento"
	L["Choose what tooltips to anchor to the mouse cursor, instead of displaying in their default positions:"] = "Escolher quais dicas ancorar ao cursosr do mouse, ao invés de exibí-las em suas posições padrão:"
	L["All tooltips will be displayed in their default positions."] = "Todas as dicas serão exibidas em suas posições padrão."
	L["All tooltips will be anchored to the mouse cursor."] = "Todas as dicas serão ancoradas ao cursor do mouse."
	L["Only Units"] = "Apenas Unidades"
	L["Only unit tooltips will be anchored to the mouse cursor, while other tooltips will be displayed in their default positions."] = "Apenas dicas de unidades serão ancoradas ao cursor do mouse, enquanto que outras dicas serão exibidas em suas posições padrão."
end

-- world status: menu
do
	L["Here you can set the visibility and behaviour of various objects like the XP and Reputation Bars, the Battleground Capture Bars and more. If you wish to change their position, you can unlock them for movement with |cFF4488FF/glock|r."] = "Aqui você poder alterar a visibilidade e o comportamento de vários objetos como as Barras de EXP e Reputação, as Barras de Captura do Campo de Batalha e mais. Se deseja alterar suas posições, você pode destravá-las para movimento com |cFF4488FF/glock|r."
	L["StatusBars"] = "Barras de Estado"
	L["Show the player experience bar."] = "Exibir a barra de experiência do jogador."
	L["Show when you are at your maximum level or have turned off experience gains."] = "Exibir quando você estiver no nível máximo ou desligou os ganhos de experiência."
	L["Show the currently tracked reputation."] = "Exibir a reputação acompanhada no momento."
	L["Show the capturebar for PvP objectives."] = "Exibir a barar de captura para objetivos JxJ."
end

-- UnitFrames
do
	L["Due to entering combat at the worst possible time the UnitFrames were unable to complete the layout change.|nPlease reload the user interface with |cFF4488FF/rl|r to complete the operation!"] = "Devido à entrada em combate no pior momento possível os Quadros de Unidade foram incapazes de completar a mudança a leiaute.|nPor favor recarregue a interface de usuário com |cFF4488FF/rl|r para completar a operação!"
end

-- UnitFrames: oUF_Trinkets
do
	L["Trinket ready: "] = "Berloque pronto: "
	L["Trinket used: "] = "Berloque usado: "
	L["WotF used: "] = "DdR usado: "
end

-- UnitFrames: menu
do
	L["These options can be used to change the display and behavior of unit frames within the UI. If you wish to change their position, you can unlock them for movement with |cFF4488FF/glock|r."] = "Estas opções podem ser utilizadas para alterar a exibição e o comportamento de quadros de unidades dentro da IU. Se deseja alterar suas posições, você pode destravá-las para movimento com |cFF4488FF/glock|r."

	L["Choose what unit frames to load"] = "Escolher quais quadros de unidade carregar"
	L["Enable Party Frames"] = "Ativar Quadros de Grupos"
	L["Enable Arena Frames"] = "Ativar Quadros de Arena"
	L["Enable Boss Frames"] = "Ativar Quadros de Chefes"
	L["Enable Raid Frames"] = "Ativar Quadros de Raides"
	L["Enable MainTank Frames"] = "Ativar Quadros de TanquePrincipal"
	L["ClassBar"] = "Barra de Classe"
	L["The ClassBar is a larger display of class related information like Holy Power, Runes, Eclipse and Combo Points. It is displayed close to the on-screen CastBar and is designed to more easily track your most important resources."] = "A Barra de Classe é uma exibição maior de informações relacionadas à classe, como Poder Sagradao, Runas, Eclipse e Pontos de Combo. Ela é exibida próxima à Barra de Lançamento na tela e é desenhada para acompanhar mais facilmente seus recursos mais importantes."
	L["Enable ClassBar"] = "Ativar Barra de Classe"
	
	L["Set Focus"] = "Definição de Foco"
	L["Here you can enable and define a mousebutton and optional modifier key to directly set a focus target from clicking on a frame."] = "Aqui você pode ativar e definir um botão do mouse e uma tecla modificadora opcional para definir o alvo foco diretamente ao clicar num quadro."
	L["Enable Set Focus"] = "Ativar Definição de Foco"
	L["Enabling this will allow you to quickly set your focus target by clicking the key combination below while holding the mouse pointer over the selected frame."] = "Ativando isto você poderá definir seu foco rapidamente ao clicar a combinação de teclas abaixo ao deixar o ponteiro do mouse sobre o quadro selecionado."
	L["Modifier Key"] = "Tecla Modificadora"

	L["Enable indicators for HoTs, DoTs and missing buffs."] = "Ativar indicadores para CsTs, DsTs e bônus que faltam."
	L["This will display small squares on the party- and raidframes to indicate your active HoTs and missing buffs."] = "isto irá exibir pequenos quadrados em quadros de unidade e de grupo para indicar suas CsTs e bônus que faltam."

	--L["Auras"] = true
	L["Here you can change the settings for the auras displayed on the player- and target frames."] = "Aqui você pode alterar as definições para as auras exibidas nos quadros de jogador e alvo."
	L["Filter the target auras in combat"] = "Filtrar as auras do alvo em combate"
	L["This will filter out auras not relevant to your role from the target frame while engaged in combat, to make it easier to track your own debuffs."] = "Isto irá filtrar auras do alvo não relevantes para você quando em combate, para tornar mais fácil o acompanhamento de suas próprias penalidades."
	L["Desature target auras not cast by the player"] = "Remover saturação de auras do alvo não lançadas pelo jogador"
	L["This will desaturate auras on the target frame not cast by you, to make it easier to track your own debuffs."] = "Isto irá remover a saturação de auras no quadro do alvo não lançadas por você, para tornar mais fácil o acompanhamento de suas próprias penalidades."
	L["Texts"] = "Textos"
	L["Show values on the health bars"] = "Exibir valores nas barras de vida"
	L["Show values on the power bars"] = "Exibir valores nas barras de poder"
	L["Show values on the Feral Druid mana bar (when below 100%)"] = "Exibir valores na barra de mana do Druida Feral (quando abaixo de 100%)"
	
	L["Groups"] = "Grupos"
	L["Here you can change what kind of group frames are used for groups of different sizes."] = "Aqui você pode alterar quais tipos de grupos de quadros são utilizados para grupos de diferentes tamanhos."

	L["5 Player Party"] = "Grupo de 5 Jogadores"
	L["Use the same frames for parties as for raid groups."] = "Utilizar os mesmos quadros para grupos e raides."
	L["Enabling this will show the same types of unitframes for 5 player parties as you currently have chosen for 10 player raids."] = "Ativando isto irá exibir os mesmos tipos de quadros de unidades para grupos de 5 jogadores e também para raides de 10 jogadores."
	
	L["10 Player Raid"] = "Raide de 10 Jogadores"
	L["Use same raid frames as for 25 player raids."] = "Utilizar os mesmos quadros de raide também para raides de 25 jogadores."
	L["Enabling this will show the same types of unitframes for 10 player raids as you currently have chosen for 25 player raids."] = "Ativando isto irá exibir os mesmos tipos de quadros de unidades para raides de 10 jogadores e também para raides de 25 jogadores."

	L["25 Player Raid"] = "Raide de 25 Jogadores"
	L["Automatically decide what frames to show based on your current specialization."] = "Decidir automaticamente quais quadros mostrar baseado em sua especialização atual."
	L["Enabling this will display the Grid layout when you are a Healer, and the smaller DPS layout when you are a Tank or DPSer."] = "Ativando isto irá exibir o leiaute de Grade quando você for um Curador, e o leiaute menor de DPS quando você for um Tanque ou DPS."
	L["Use Healer/Grid layout."] = "Utilizar o leiaute de Curador/Grade"
	L["Enabling this will use the Grid layout instead of the smaller DPS layout for raid groups."] = "Ativando isto irá utilizar o leiaute de Grade ao invés do leiaute DPS menor para grupos de raide."
	
	L["Player"] = "Jogador"
	L["ClassBar"] = "Barra de Classe"
	L["The ClassBar is a larger display of class related information like Holy Power, Runes, Eclipse and Combo Points. It is displayed close to the on-screen CastBar and is designed to more easily track your most important resources."] = "A Barra de Classe é uma exibição maior de informações relacionadas à classe, como Poder Sagradao, Runas, Eclipse e Pontos de Combo. Ela é exibida próxima à Barra de Lançamento na tela e é desenhada para acompanhar mais facilmente seus recursos mais importantes."
	L["Enable large movable classbar"] = "Ativar barra de classe grande móvel"
	L["This will enable the large on-screen classbar"] = "Isto irá ativar a barra de classe grande na tela"
	L["Only in Combat"] = "Apenas em Combate"	
	L["Disable integrated classbar"] = "Desativar barra de classe integrada"
	L["This will disable the integrated classbar in the player unitframe"] = "Isto irá desativar a bara de classe integrada no quadro de unidade do jogador"
	L["Show player auras"] = "Exibir auras do jogador"
	L["This decides whether or not to show the auras next to the player frame"] = "Isto decide se devem ou não serem exibidas as auras próximas ao quadro do jogador"
	
	L["Target"] = "Alvo"
	L["Show target auras"] = "Exibir auras do alvo"
	L["This decides whether or not to show the auras next to the target frame"] = "Isto decide se devem ou não serem exibidas as auras próximas ao quadro do alvo"
end

-- UnitFrames: GroupPanel
do
	-- party
	L["Show the player along with the Party Frames"] = "Exibir o jogador junto com os Quadros de Grupo"
	L["Use Raid Frames instead of Party Frames"] = "Utilizar Quadros de Raide ao invés de Quadros de Grupo"
	
	-- raid
	L["Use the grid layout for all Raid sizes"] = "Utilizar o leiaute de grade para todos os tamanhos de Raide"
end


--------------------------------------------------------------------------------------------------
--		FAQ
--------------------------------------------------------------------------------------------------
-- 	Even though most of these strings technically belong to their respective modules,
--		and not the FAQ interface, we still gather them all here for practical reasons.
do
	-- general
	L["FAQ"] = true
	L["Frequently Asked Questions"] = "Perguntas Frequentes"
	L["Clear All Tags"] = "Limpar Todas as Marcações"
	L["Show the current FAQ"] = "Exibir o FAQ atual"
	L["Return to the listing"] = "Retornar à lista"
	L["Go to the options menu"] = "Ir para o menu de opções"
	L["Select categories from the list on the left. |nYou can choose multiple categories at once to narrow down your search.|n|nSelected categories will be displayed on top of the listing, |nand clicking them again will deselect them!"] = "Selecionar categorias da lista à esquerda.|nVocê pode escolher múltiplas categorias de uma vez para diminuir sua busca.|n|nAs categorias selecionadas serão exibidas no topo da lista,|ne ao clicar sobre elas novamente as removerá da seleção!"
	
	-- core
	L["I wish to move something! How can I change frame positions?"] = "Eu desejo mover algo! Como posso alterar as posições dos quadros?"
	L["A lot of frames can be moved to custom positions. You can unlock them all for movement by typing |cFF4488FF/glock|r followed by the Enter key, and lock them with the same command. There are also multiple options available when right-clicking on the overlay of the movable frame."] = "Vários quadros podem ser movidos para posições personalizadas. Você pode destravá-los todos para movimento digitando |cFF4488FF/glock|r seguido da tecla Enter, e travá-los com o mesmo comando. Há também diversas opções disponíveis com o clique-direito na camada do quadro móvel."

	-- actionbars
	L["How do I change the currently active Action Page?"] = "Como eu altero a Página de Ação ativa?"
	L["There are no on-screen buttons to do this, so you will have to use keybinds. You can set the relevant keybinds in the Blizzard keybinding interface."] = "Não há botões na tela para fazer isso, então você terá de usar teclas de atalho. Você pode definir as teclas de atalho relevantes na interface de Teclas de Atalho da Blizzard."
	L["How can I change the visible actionbars?"] = "Como eu altero as barras de ação visíveis?"
	L["You can toggle most actionbars by clicking the arrows located close to their corners. These arrows become visible when hovering over them with the mouse if you're not currently engaged in combat. You can also toggle the actionbars from the options menu, or by running the install tutorial by typing |cFF4488FF/install|r followed by the Enter key."] = "Você pode ativar/desativar a maiora das barras de ação clicando nas setas localizadas próximas ao seus cantos. Estas setas se tornam visíveis ao passar o mouse sobre elas se você não estiver em combate no momento. Você pode também ativar/desativar as barras de ação pelo menu de opções, ou simplismente rodando o tutorial de instalação digitando |cFF4488FF/install|r seguido da tecla Enter."
	L["How do I toggle the MiniMenu?"] = "Como eu ativo/desativo o MiniMenu?"
	L["The MiniMenu can be displayed by typing |cFF4488FF/showmini|r followed by the Enter key, and |cFF4488FF/hidemini|r to hide it. You can also toggle it from the options menu or by running the install tutorial by typing |cFF4488FF/install|r."] = "O MiniMenu pode ser exibido digitando |cFF4488FF/showmini|r seguido da tecla Enter, e |cFF4488FF/hidemini|r para escondê-lo. Você pode também ativar/desativar ele pelo menu de opções, ou simplismente rodando o tutorial de instalação digitando |cFF4488FF/install|r seguido da tecla Enter."
	L["How can I move the actionbars?"] = "Como eu posso mover as barras de ação?"
	L["Not all actionbars can be moved, as some are an integrated part of the UI layout. Most of the movable frames in the UI can be unlocked by typing |cFF4488FF/glock|r followed by the Enter key."] = "Nem todas as barras de ação podem ser movidas, já que algumas são partes integradas do leiaute da IU. A maioria dos quadros móveis podem ser destravados digitando |cFF4488FF/glock|r seguido da tecla Enter."
	
	-- actionbuttons
	L["How can I toggle keybinds and macro names on the buttons?"] = "Como eu ativo/desativo os nomes de atalhos e macros nos botões?"
	L["You can enable keybind display on the actionbuttons by typing |cFF4488FF/showhotkeys|r followed by the Enter key, and disable it with |cFF4488FF/hidehotkeys|r. Macro names can be toggled with the |cFF4488FF/shownames|r and |cFF4488FF/hidenames|r commands. All settings can also be changed in the options menu."] = "Você pode ativar a exibição de atalhos nos botões de ação digitando |cFF4488FF/showhotkeys|r seguido da tecla Enter, e desativar eles com |cFF4488FF/hidehotkeys|r. Nomes de macros podem ser ativados/desativados com os comandos |cFF4488FF/shownames|r e |cFF4488FF/hidenames|r respectivamente."
	
	-- auras
	L["How can I change how my buffs and debuffs look?"] = "Como eu posso alterar como os bônus e penalidades aparecem?"
	L["You can change a lot of settings like the time display and the cooldown spiral in the options menu."] = "Você pode alterar várias definições como a exibição de tempo e a espiral de recarga no menu de opções."
	L["Sometimes the weapon buffs don't display correctly!"] = "Algumas vezes os bônus de armas não são exibidos corretamente!"
	L["Correct. Sadly this is a bug in the tools Blizzard has given to us addon developers, and not something that is easily fixed. You'll simply have to live with it for now."] = "Correto. Lamentavelmente este é um bug nas ferramentas que a Blizzard forneceu para nós desenvolvedores de addons, e não algo que é facilmente corrigido. Você simplesmente terá de viver com isso por hora."
	
	-- bags
	L["Sometimes when I choose to bypass a category, not all items are moved to the '%s' container, but some appear in others?"] = "Algumas vezes quando eu escolho ignorar a categoria, nem todos os itens são movidos ao contêiner '%s', mas alguns aparecem em outros?"
	L["Some items are put in the 'wrong' categories by Blizzard. Each category in the bag module has its own internal filter that puts these items in their category of they are deemed to belong there. If you bypass this category, the filter is also bypassed, and the item will show up in whatever category Blizzard originally put it in."] = "Alguns itens são colocados nas categorias 'erradas' pela Blizzard. Cada categoria no módulo de bolsas tem seu próprio filtro interno que coloca estes itens nas categorias que eles são considerados a pertencer. Se você ignora a categoria, o filtro também é ignorado, e o item será exibido em qualquer categoria que a Blizzard originalmente o colocou."
	L["How can I change what categories and containers I see? I don't like the current layout!"] = "Como eu posso alterar quais categorias e contêineres eu vejo? Eu não gosto do leiaute atual!"
	L["Categories can be quickly selected from the quickmenu available by clicking at the arrow next to the '%s' or '%s' containers."] = "As categorias podem ser rapidamente selecionadas do menu rápido disponível ao clicar sobre a seta próxima aos contêineres '%s' ou '%s'."
	L["You can change all the settings in the options menu as well as activate the 'all-in-one' layout easily!"] = "Você pode alterar todas as definições no menu de opções assim como ativar o leiaute 'tudo-em-um' facilmente!"
	L["How can I disable the bags? I don't like them!"] = "Como eu posso desativar as bolsas? Eu não gosto delas!"
	L["All the modules can be enabled or disabled from within the options menu. You can locate the options menu from the button on the Game Menu, or by typing |cFF4488FF/gui|r followed by the Enter key."] = "Todos os módulos podem ser ativados ou desativados a partir do menu de opções. Você pode localizar o menu de opções no Menu do Jogo, ou digitando |cFF4488FF/gui|r seguido da tecla Enter."
	L["I can't close my bags with the 'B' key!"] = "Eu não posso fechar minhas bolsas com a tecla 'B'!"
	L["This is because you probably have bound the 'B' key to 'Open All Bags', which is a one way function. To have the 'B' key actually toggle the containers, you need to bind it to 'Toggle Backpack'. The UI can reassign the key for you automatically. Would you like to do so now?"] = "Isto é por que você provavelmente vinculou a tecla 'B' à função 'Abrir Todas as Bolsas', que é uma função de abertura apenas. Para ter a tecla 'B' realmente alternando a abertura dos contêineres, você precisa vincular ela à função 'Ativar/Desativar Mochila'. A IU pode ajustar a tecla para você automaticamente. Gostaria de fazer isso agora?"
	L["Let the 'B' key toggle my bags"] = "Fazer com que a tecla 'B' abra/feche minhas bolsas"
	
	-- castbars
	L["How can I toggle the castbars for myself and my pet?"] = "Como eu posso ativar/desativar as barras de lançamento para mim e meu ajudante?"
	L["The UI features movable on-screen castbars for you, your target, your pet, and your focus target. These bars can be positioned manually by typing |cFF4488FF/glock|r followed by the Enter key. |n|nYou can change their settings, size and visibility in the options menu."] = "A IU possui barras de lançamento móveis na tela para você, seu alvo, seu ajudante, e o foco do seu alvo. Estas barras podem ser posicionadas manualmente digitando |cFF4488FF/glock|r seguido da tecla Enter.|n|nVocê pode alterar suas definições, tamanhos e visibilidades no menu de opções."
	
	-- minimap
	L["I can't find the Calendar!"] = "Eu não consigo encontrar o Calendário!"
	L["You can open the calendar by clicking the middle mouse button while hovering over the Minimap, or by assigning a keybind to it in the Blizzard keybinding interface avaiable from the GameMenu. The Calendar keybind is located far down the list, along with the GUIS keyinds."] = "Você pode abrir o calendário ao clicar com o botão do meio do mouse em cima do Minimapa, ou definindo uma tecla de atalho para ele na interface de Teclas de Atalho da Blizzard disponível no Menu do Jogo. A tecla de atalho do calendário está no final da lista, junto com os atalhos do GUIS."
	L["Where can I see the current dungeon- or raid difficulty and size when I'm inside an instance?"] = "Onde eu posso ver a dificuldade e o tamanho da masmorra ou raide atual quando estou dentro de uma instância?"
	L["You can see the maximum size of your current group by hovering the cursor over the Minimap while being inside an instance. If you currently have activated Heroic mode, a skull will be visible next to the size display as well."] = "Você pode ver o tamanho máximo do grupo atual passando o cursor sobre o Minimapa quando numa instância. Se você ativou o modo Heróico, uma caveira estará visível próximo à exibição do tamanho também."
	L["How can I move the Minimap?"] = "Como eu posso mover o Minimapa?"
	L["You can manually move the Minimap as well as many other frames by typing |cFF4488FF/glock|r followed by the Enter key."] = "Você pode mover o Minimapa manualmente assim como outros quadros digitando |cFF4488FF/glock|r seguido da tecla Enter"
	
	-- quests
	L["How can I move the quest tracker?"] = "Como eu posso mover o acompanhador de missões?"
	L["My actionbars cover the quest tracker!"] = "Minhas barras de ação estão cobrindo o acompanhador de missões!"
	L["You can manually move the quest tracker as well as many other frames by typing |cFF4488FF/glock|r followed by the Enter key. If you wish the quest tracker to automatically move in relation to your actionbars, then reset its position to the default. |n|nWhen a frame is unlocked with the |cFF4488FF/glock|r command, you can right click on its overlay and select 'Reset' to return it to its default position. For some frames like the quest tracker, this will allow the UI to decide where it should be put."] = "Você pode mover o acompanhador de missões manualmente assim como muitos outros quadros digitando |cFF4488FF/glock|r seguido da tecla Enter. Se você deseja que o acompanhador de missões se mova automaticamente em relação às suas barras de ação, então resete sua posição para o padrão.|n|nQuando um quadro está destravado com o comando |cFF4488FF/glock|r, você pode clicar com o botão direito em sua cama e selecionar 'Resetar' para retornar à sua posição padrão. Para alguns quadros como o acompanhador de missões, isto permitirá que a IU saiba onde colocá-lo."
	
	-- talents
	L["I can't close the Talent Frame when pressing 'N'"] = "Eu não posso fechar o Quadro de Talentos pressionando 'N'"
	L["But you can still close it!|n|nYou can close it with the Escacpe key, or the closebutton located in he upper right corner of the Talent Frame.|n|nWhen closing the Talent Frame with the original keybind to toggle it, it becomes 'tainted'. This means that the game considers it to be 'insecure', and you won't be allowed to do actions like for example changing your glyphs. This only happens when closed with the hotkey, not when it's closed by the Escape key or the closebutton.|n|nBy reassigning your Talent Frame keybind to a function that only opens the frame, not toggles it, we have made sure that it gets closed the proper way, and you can continue to change your glyphs as intended."] = "Mas você ainda pode fechá-lo!|n|nVocê pode fechá-lo com a tecla Esc, ou com o botão de fechar localizado no canto direito superior do Quadro de Talentos.|n|nAo fechar o Quadro de Talentos com a tecla de atalho original, ele fica 'manchado'.Isto significa que o jogo o considera 'inseguro', e que você não poderá realizar ações, como por exemplo mudar seus glifos. Isto acontece apenas quando fechado com a tecla de atalho, não quando fechado com a tecla Esc ou o botão de fechar.|n|nAo definir o seu atalho para o Quadro de Talentos a uma função que apenas abre a janela, não alterna seu estado, nós garantimos que ele será fechado da maneira correta, e você poderá continuar a alterar seus glifos como desejar."
	
	-- tooltips
	L["How can I toggle the display of player realms and titles in the tooltips?"] = "Como eu posso ativar/desativar a exibição dos reinos e títulos do jogador nas dicas?"
	L["You can change most of the tooltip settings from the options menu."] = "Você pode alterar a maioria das definições das dicas no menu de opções."
	
	-- unitframes
	L["My party frames aren't showing!"] = "Meus quadros de grupo não estão aparecendo!"
	L["My raid frames aren't showing!"] = "Meus quadros de raide não estão aparecendo!"
	L["You can set a lot of options for the party- and raidframes from within the options menu."] = "Você pode definir diversas opções para os quadros de raides e grupos a partir do menu de opções."
	
	-- worldmap
	L["Why do the quest icons on the WorldMap disappear sometimes?"] = "Por que os ícones de missões no Mapa-Múndi desaparecem em alguns momentos?"
	L["Due to some problems with the default game interface, these icons must be hidden while being engaged in combat."] = "Devido a problemas com a interface padrão do jogo, estes ícones devem estar escondidos em combate."
end


--------------------------------------------------------------------------------------------------
--		Chat Command List
--------------------------------------------------------------------------------------------------
-- we're doing this in the worst possible manner, just because we can!
do
	local separator = "€€€"
	local cmd = "|cFF4488FF/glock|r - trava/destrava os quadros para movimento"
	cmd = cmd .. separator .. "|cFF4488FF/greset|r - reseta a posição de quadros móveis"
	cmd = cmd .. separator .. "|cFF4488FF/resetbars|r - reseta a posição apenas de barras de ação móveis"
	cmd = cmd .. separator .. "|cFF4488FF/resetbags|r - retorna as bolsas às suas posições padrão"
	cmd = cmd .. separator .. "|cFF4488FF/scalebags|r X - define a escala de bolsas, onde o X é um número de 1.0 a 2.0"
	cmd = cmd .. separator .. "|cFF4488FF/compressbags|r - ativa/desativa a compressão de espaços vazios nas bolsas"
	cmd = cmd .. separator .. "|cFF4488FF/showsidebars|r, |cFF4488FF/hidesidebars|r - ativa/desativa a exibição das barras de ação de ambos os lados"
	cmd = cmd .. separator .. "|cFF4488FF/showrightbar|r, |cFF4488FF/hiderightbar|r - ativa/desativa a exibição da barra de ação mais à direita"
	cmd = cmd .. separator .. "|cFF4488FF/showleftbar|r, |cFF4488FF/hideleftbar|r - ativa/desativa a exibição da barra de ação mais à esquerda"
	cmd = cmd .. separator .. "|cFF4488FF/showpet|r, |cFF4488FF/hidepet|r - ativa/desativa a exibição da barra de ação do ajudante"
	cmd = cmd .. separator .. "|cFF4488FF/showshift|r, |cFF4488FF/hideshift|r - ativa/desativa a exibição da barra de ação de forma/postura/aspecto"
	cmd = cmd .. separator .. "|cFF4488FF/showtotem|r, |cFF4488FF/hidetotem|r - ativa/desativa a exibição da barra de totem"
	cmd = cmd .. separator .. "|cFF4488FF/showmini|r, |cFF4488FF/hidemini|r - ativa/desativa a exibição do mini/micromenu"
	cmd = cmd .. separator .. "|cFF4488FF/rl|r - recarrega a interface de usuário"
	cmd = cmd .. separator .. "|cFF4488FF/gm|r - abre o quadro de ajuda"
	cmd = cmd .. separator .. "|cFF4488FF/showchatbrackets|r - exibe colchetes em volta dos nomes de jogadores e canais no bate-papo"
	cmd = cmd .. separator .. "|cFF4488FF/hidechatbrackets|r - esconde os colchetes em volta dos nomes de jogadores e canais no bate-papo"
	cmd = cmd .. separator .. "|cFF4488FF/chatmenu|r - abre o menu do quadro de bate-papo"
	cmd = cmd .. separator .. "|cFF4488FF/mapmenu|r - abre o menu do clique-do-meio do Minimapa"
	cmd = cmd .. separator .. "|cFF4488FF/tt|r or |cFF4488FF/wt|r - sussurra para o seu alvo atual"
	cmd = cmd .. separator .. "|cFF4488FF/tf|r or |cFF4488FF/wf|r - sussurra para o foco do seu alvo atual"
	cmd = cmd .. separator .. "|cFF4488FF/showhotkeys|r, |cFF4488FF/hidehotkeys|r - ativa/desativa a exibição de atalhos nos botões de ação"
	cmd = cmd .. separator .. "|cFF4488FF/shownames|r, |cFF4488FF/hidenames|r - ativa/desativa a exibição dos nomes das macros nos botões de ação"
	cmd = cmd .. separator .. "|cFF4488FF/enableautorepair|r - ativar o reparo automático da sua armadura"
	cmd = cmd .. separator .. "|cFF4488FF/disableautorepair|r - desativar o reparo automático da sua armadura"
	cmd = cmd .. separator .. "|cFF4488FF/enableguildrepair|r - utilizar os fundos da guilda quando disponíveis para reparar sua armadura"
	cmd = cmd .. separator .. "|cFF4488FF/disableguildrepair|r - desativar a utilização de fundos da guilda quando disponíveis para seus reparos"
	cmd = cmd .. separator .. "|cFF4488FF/enableautosell|r - ativar a venda automática de saques de baixa qualidade"
	cmd = cmd .. separator .. "|cFF4488FF/disableautosell|r - desativar a venda automática de saques de baixa qualidade"
	cmd = cmd .. separator .. "|cFF4488FF/enabledetailedreport|r - exibe um relatório detalhado por venda de itens de baixa qualidade"
	cmd = cmd .. separator .. "|cFF4488FF/disabledetailedreport|r - desativa os relatórios detalhados e exibe apenas os totais"
	cmd = cmd .. separator .. "|cFF4488FF/mainspec|r - ativar sua especialização de talentos principal"
	cmd = cmd .. separator .. "|cFF4488FF/offspec|r - ativar sua especialização de talentos secundária"
	cmd = cmd .. separator .. "|cFF4488FF/togglespec|r - alternar entre suas especializações de talentos"
	cmd = cmd .. separator .. "|cFF4488FF/ghelp|r - exibir este menu"
	L["chatcommandlist-separator"] = separator
	L["chatcommandlist"] = cmd
end


--------------------------------------------------------------------------------------------------
--		Keybinds Menu (Blizzard)
--------------------------------------------------------------------------------------------------
do
	L["Toggle Calendar"] = "Mostrar/ocultar Calendário"
	L["Whisper focus"] = "Foco do sussurro"
	L["Whisper target"] = "Alvo do sussurro"
end


--------------------------------------------------------------------------------------------------
--		Error Messages 
--------------------------------------------------------------------------------------------------
do
	L["Can't toggle Action Bars while engaged in combat!"] = "Não pode ativar/desativar as Barras de Ação em combate!"
	L["Can't change Action Bar layout while engaged in combat!"] = "Não pode alterar o leiaute da Barra de Ação em combate!"
	L["Frames cannot be moved while engaged in combat"] = "Os quadros não podem ser movidos em combate"
	L["Hiding movable frame anchors due to combat"] = "Escondendo âncoras de quadros móveis devido ao combate"
	L["UnitFrames cannot be configured while engaged in combat"] = "Quadros de Unidades não podem ser configurados em combate"
	L["Can't initialize bags while engaged in combat."] = "Não pode inicializar ps sacps em combate."
	L["Please exit combat then re-open the bags!"] = "Por favor saia do combate e então abra novamente as bolsas!"
end


--------------------------------------------------------------------------------------------------
--		Core Messages
--------------------------------------------------------------------------------------------------
do
	L["Goldpaw"] = "|cFFFF7D0AGoldpaw|r" -- my class colored name. no changes needed here.
	L["The user interface needs to be reloaded for the changes to take effect. Do you wish to reload it now?"] = "A interface de usuário precisa ser recarregada para que as mudanças tenham efeito. Deseja recarregar agora?"
	L["You can reload the user interface at any time with |cFF4488FF/rl|r or |cFF4488FF/reload|r"] = "Você pode recarregar a interface de usuário a qualquer momento com |cFF4488FF/rl|r ou |cFF4488FF/reload|r"
	L["Can not apply default settings while engaged in combat."] = "Não pode aplicar as definições padrão em combate."
	L["Show Talent Pane"] = "Exibir Painel de Talentos"
end

-- menu
do
	L["UI Scale"] = "Escala da IU"
	L["Use UI Scale"] = "Utilizar Escala da IU"
	L["Check to use the UI Scale Slider, uncheck to use the system default scale."] = "Marque para utilizar a Barra de Escala da IU, desmarque para utilizar a escala padrão do sistema."
	L["Changes the size of the game’s user interface."] = "Altera o tamanho da interface de usuário do jogo."
	L["Using custom UI scaling is not recommended. It will produce fuzzy borders and incorrectly sized objects."] = "Utilizar a escala de IU personalizada não é recomendado. Ela irá produzir bordas borradas e objetos de tamanhos incorretos."
	L["Apply the new UI scale."] = "Aplicar a nova escala da IU."
	L["Load Module"] = "Carregar Módulo"
	L["Module Selection"] = "Seleção de Módulos"
	L["Choose which modules should be loaded, and when."] = "Escolher quais módulos devem ser carregados, e quando."
	L["Never load this module"] = "Nunca carregar este módulo"
	L["Load this module unless an addon with similar functionality is detected"] = "Carregar este módulo a não ser que um addon com funcionalidade parecida for detectado"
	L["Always load this module, regardles of what other addons are loaded"] = "Sempre carregar este módulo, independente de quais outros addons serem carregados"
	L["(In Development)"] = "(Em Desenvolvimento)"
end

-- install tutorial
do
	-- general install tutorial messages
	L["Skip forward to the next step in the tutorial."] = "Pular para o próximo passo no tutorial."
	L["Previous"] = "Anterior"
	L["Go backwards to the previous step in the tutorial."] = "Voltar ao passo anterior no tutorial."
	L["Skip this step"] = "Pular este passo"
	L["Apply the currently selected settings"] = "Aplicar as definições selecionadas no momento"
	L["Procede with this step of the install tutorial."] = "Proceder com este passo do tutorial de instalação."
	L["Cancel the install tutorial."] = "Cancelar o tutorial de instalação."
	L["Setup aborted. Type |cFF4488FF/install|r to restart the tutorial."] = "Instalação abortada. Digite |cFF4488FF/install|r para reiniciar o tutorial."
	L["Setup aborted because of combat. Type |cFF4488FF/install|r to restart the tutorial."] = "Instalação abortada devido ao combate. Digite |cFF4488FF/install|r para reiniciar o tutorial."
	L["This is recommended!"] = "Isto é recomendado!"

	-- core module's install tutorial
	L["This is the first time you're running %s on this character. Would you like to run the install tutorial now?"] = "Esta é a primeira vez que você está rodando o %s neste personagem. Gostaria de iniciar o tutorial de instalação agora?"
	L["Using custom UI scaling will distort graphics, create fuzzy borders, and otherwise ruin frame proportions and positions. It is adviced to always leave this off, as it will seriously affect the entire layout of the UI in unpredictable ways."] = "Utilizar escala de IU personalizada irá distorcer os gráficos, criar bordas borradas, e de certa forma acabar com as proporções e posições dos quadros. É recomendado sempre deixar isto desligado, já que irá afetar todo o leiaute da IU de maneiras imprevisíveis."
	L["UI scaling is currently activated. Do you wish to disable this?"] = "A escala de IU está ativada no momento. Deseja desativá-la?"
	L["|cFFFF0000UI scaling is currently deactivated, which is the recommended setting, so we are skipping this step.|r"] = "|cFFFF0000A escala de IU está desativada, o que é a definição recomendada, então estamos pulando este passo.|r"
end

-- general 
-- basically a bunch of very common words, phrases and abbreviations
-- that several modules might have need for
do
	L["R"] = "Vm" -- R as in Red
	L["G"] = "Vd" -- G as in Green
	L["B"] = "Az" -- B as in Blue
	L["A"] = "Tr"	-- A as in Alpha (for opacity/transparency)

	L["m"] = true -- minute
	L["s"] = true -- second
	L["h"] = true -- hour
	L["d"] = true -- day

	L["Alt"] = true -- the ALT key
	L["Ctrl"] = true -- the CTRL key
	L["Shift"] = true -- the SHIFT key
	L["Mouse Button"] = "Botão do Mouse"

	L["Always"] = "Sempre"
	L["Apply"] = "Aplicar"
	L["Bags"] = "Bolsas"
	L["Bank"] = "Banco" 
	L["Bottom"] = "Base"
	L["Cancel"] = "Cancelar"
	L["Categories"] = "Categorias"
	L["Close"] = "Fechar"
	L["Continue"] = "Continuar"
	L["Copy"] = "Copiar" -- to copy. the verb.
	L["Default"] = "Padrão"
	L["Elements"] = "Elementos" -- like elements in a frame, not as in fire, ice etc
	L["Free"] = "Livres" -- free space in bags and bank
	L["General"] = "Geral" -- general as in general info
	L["Ghost"] = "Fantasma" -- when you are dead and have released your spirit
	L["Hide"] = "Esconder" -- to hide something. not hide as in "thick hide".
	L["Lock"] = "Travar" -- to lock something, like a frame. the verb.
	L["Main"] = "Principal" -- used for Main chat frame, Main bag, etc
	L["Next"] = "Próximo"
	L["Never"] = "Nunca"
	L["No"] = "Não"
	L["Okay"] = "Ok"
	L["Open"] = "Abrir"
	L["Paste"] = "Colar" -- as in copy & paste. the verb.
	L["Reset"] = "Resetar"
	L["Rested"] = "Descansado" -- when you are rested, and will recieve 200% xp from kills
	L["Scroll"] = "Pergaminho" -- "Scroll" as in "Scroll of Enchant". The noun, not the verb.
	L["Show"] = "Exibir"
	L["Skip"] = "Ignorar"
	L["Top"] = "Topo"
	L["Total"] = "Total"
	L["Visibility"] = "Visibilidade"
	L["Yes"] = "Sim"

	L["Requires the UI to be reloaded!"] = "Requer que a IU seja recarregada!"
	L["Changing this setting requires the UI to be reloaded in order to complete."] = "A alteração desta definição requer que a IU seja recarregada para ser completa."
end

-- gFrameHandler replacements (/glock)
do
	L["<Left-Click and drag to move the frame>"] = "<Clique-Esquerdo e arrastar para mover o quadro>"
	L["<Left-Click+Shift to lock into position>"] = "<Clique-Esquerdo+Shift para travar no posição>"
	--L["<Right-Click for options>"] = true -- the panel module supplies this one
	L["Center horizontally"] = "Centralizar horizontalmente"
	L["Center vertically"] = "Centralizar verticalmente"
end

-- visible module names
do
	L["ActionBars"] = "Barras de Ação"
	L["ActionButtons"] = "Botões de Ação"
	L["Auras"] = "Auras"
	L["Bags"] = "Bolsas"
	L["Buffs & Debuffs"] = "Bônus e Penalidades"
	L["Castbars"] = "Barras de Lançamento"
	L["Core"] = "Núcleo"
	L["Chat"] = "Bate-Papo"
	L["Combat"] = "Combate"
	L["CombatLog"] = "Registro de Combate"
	L["Errors"] = "Erros"
	L["Loot"] = "Saque"
	L["Merchants"] = "Mercado"
	L["Minimap"] = "Minimapa"
	L["Nameplates"] = "Placas de Nomes"
	L["Quests"] = "Missões"
	L["Timers"] = "Temporizadores"
	L["Tooltips"] = "Dicas"
	L["UI Panels"] = "Painéis de IU"
	L["UI Skinning"] = "Skin de IU"
	L["UnitFrames"] = "Quadros de Unidades"
		L["PartyFrames"] = "Quadros de Grupo"
		L["ArenaFrames"] = "Quadros de Arena"
		L["BossFrames"] = "Quadros de Chefe"
		L["RaidFrames"] = "Quadros de Raide"
		L["MainTankFrames"] = "Quadros de TanquePrincipal"
	L["World Status"] = "Situação do Mundo"
end

-- various stuff used in the install tutorial's intro screen
do
	L["Credits to: "] = "Créditos a: "
	L["Web: "] = true
	L["Download: "] = true
	L["Twitter: "] = true
	L["Facebook: "] = true
	L["YouTube: "] = true
	L["Contact: "] = "Contato: " 

	L["_ui_description_"] = "O %s é uma interface de usuário completa para o World of Warcraft, concebido como um substituto à IU padrão da Blizzard. Ele suporta resoluções de tela desde 1280 pixels de largura, mas um mínimo de 1440 é recomendado.|n|nA IU foi escrita e é mantida por Lars Norberg, que joga como o Druida Feral %s localizado no Reino Draenor EU PvE, do lado da Aliança."
	
	L["_install_guide_"] = "Em alguns pequenos passos você será guiado através do processo de instalação de alguns dos módulos nesta interface de usuário. Você pode sempre alterar as opç~es posteriormente do menu de opções disponível a partir do menu principal do jogo, ou digitando-se |cFF4488FF/gui|r."
	
	L["_ui_credited_"] = "Rogueh(frFR), Banz Lin(enCN, enTW, zhCN, zhTW), UnoPrata(ptBR) and Kkthnxbye(compability)"

	L["_ui_copyright_"] = "Direitos Autorais (c) 2012, Lars '%s' Norberg. Todos os direitos reservados."

	-- nothing to localize on the following, I just put them here for easy reference
	L["_ui_web_"] = "www.friendlydruid.com"
	L["_ui_download_"] = "www.curse.com/addons/wow/guis-gui"
	L["_ui_facebook_"] = "www.facebook.com/goldpawguisgui"
	L["_ui_twitter_"] = "twitter.com/friendlydruid"
	L["_ui_youtube_"] = "www.youtube.com/user/FriendlyDruidTV"
	L["_ui_contact_"] = "goldpaw@friendlydruid.com"
end
