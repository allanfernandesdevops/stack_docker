# STACK DE DESENVOLVIMENTO - TEC

## PRÉ-REQUISITOS ##

- ### GIT

- ### DOCKER
    - Linux (Debian like!)

        1. Atualize seu ambiente:

            ```
            sudo apt update
            ```
            
        2. Adicione as dependências do docker:
            ```
            sudo apt install apt-transport-https ca-certificates curl software-properties-common
            ```        

        3. Adicione a chave do repositório oficial do docker no keyring:
            ```
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
            ```
        4. Adicione o repositório do docker no PPA:
            ```
            sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
            ```
        5. Atualize a lista de pacotes:
            ```
            sudo apt update
            ```

        6. Baixe o docker:
            ```
            sudo apt install docker-ce
            ```

        7. Verifique se o serviço está rodando e habilitado:
            ```
            sudo systemctl status docker
            ```

        8. Adicione o usuário atual ao grupo de permissões do docker:
            ```
            sudo usermod -aG docker $USER
            ```

        9. Baixe o docker compose:
            ```
            sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
            ```

        10. Marque o docker compose como executável:
            ```
            sudo chmod +x /usr/local/bin/docker-compose
            ```

        11. Reinicie a sua sessão.



    - Linux (Red hat like!)

- ### AMBIENTE

Antes de iniciar a configuração, é necessário que já tenha configurado sua chave ssh na sua conta do bitbucket caso não, siga estes passos:
  - Linux

    - Configurar chave SSH no Bitbucket
    É necessário configurar as chaves ssh de acesso ao repositório da **API, SISTEMA e NG**.
    
    - No seu terminal, crie a chave usando o comando: ssh-keygen -t rsa -C "seu-email@tec.com.br".
    
    - Copie o conteúdo da chave pública criada: cat ~/.ssh/id_rsa.pub.
    - Acesse o site do bitbucket e faça o login:
    - Clique no seu avatar (canto superior direto).
    - Clique em "Personal Settings".
    - Acesse o menu esquerdo "SSH keys" e adicione a sua chave pública.

- ### STACK
  - Após cumprir todos os pré-requisitos, executar o script **do** que realiza a configuração da stack local.

## IMPORTANTE ##

Se você estiver usando Linux, os comandos da stack deverão ser executados em um terminal bash.