# 🩻 Wall System

## ❗ Utilização do Sistema

Este sistema, por padrão, não utiliza comunicação contínua entre cliente e servidor. Em vez disso, adota um mecanismo de ***state bags*** individuais para cada jogador, o que resulta em uma otimização significativa da rede do servidor. Esta é a primeira versão do sistema; caso encontre algum bug, pedimos que reporte o mais rapidamente possível ao responsável.

## 💻 Instalação

Para a instalação do sistema, é necessário adaptar o código de acordo com a sua base, especificamente no que diz respeito às permissões, passaporte, identidade e emprego. Além disso, para que o sistema funcione corretamente, é imprescindível adicionar o sistema de ***state bags***, conforme descrito abaixo, a ser ativado assim que o jogador se conectar ao servidor.

Não é recomendado atualizar essas informações, a menos que o jogador faça o relogin no servidor. Vale ressaltar que um dos principais problemas relacionados ao *wall* atualmente é a grande quantidade de bytes enviados entre o servidor e o cliente.

```lua
local Passport = vRP.Passport(source) or vRP.getUserId(source)
local Identity = vRP.Identity(Passport) or vRP.userIdentity(Passport)
local Jobs = vRP.UserJob(Passport,"Primary") or vRP.userJob(Passport,"Primary")

Player(source)["state"]:set("_wall",{ Passport,string.sub(Identity["name"],1,10).." "..string.sub(Identity["name2"],1,15),Jobs },true)
```

### 📱 Suporte

Em caso de dúvidas, sinta-se à vontade para entrar em contato. No entanto, tenha em mente que perguntas básicas devem ser evitadas, já que o código é totalmente aberto e permite que você faça suas próprias modificações.

> Clique [aqui](https://nohello.net/pt-br/) antes de fazer uma pergunta!


Feito com ❤️ por [swervin_](https://swervinstudio.com)