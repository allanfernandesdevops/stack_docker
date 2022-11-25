#!/bin/bash
#

from=`pwd`
work=`pwd`
installdir="$( cd "$(dirname "$0")" ; pwd -P )"


if [ "$1" == "install" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "" >> ~/.bash_profile
        echo "alias stack='$installdir/do'" >> ~/.bash_profile
        echo "export STACK_HOME=$from" >> ~/.bash_profile
        echo "Run \"source ~/.bash_profile\""
        exit
    fi

    echo "" >> ~/.bashrc
    echo "alias stack='$installdir/do'" >> ~/.bashrc
    echo "export STACK_HOME=$from" >> ~/.bashrc
    echo "Run \"source ~/.bashrc\""
    exit
fi

if [ -z "${STACK_HOME}" ]; then
    echo "Home da stack não foi configurada, execute primeiro (bash do install)"
    exit
fi

from=$STACK_HOME

cloneRepo () {
    if ! [ -d "$from/$1" ]; then
        git clone git@bitbucket.org:tec/$1.git "$from/$1"
    fi
    echo "$2 OK"
}

updateAll () {
    echo "Fixing xdebug host"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        docker exec -it tec-api sh -c "echo \"xdebug.remote_host=host.docker.internal\" >> /etc/php7/conf.d/00_xdebug.ini"
        docker exec -it tec-sistema sh -c "echo \"xdebug.remote_host=host.docker.internal\" >> /usr/local/etc/php/conf.d/xdebug.ini"
    fi

    if [[ "$OSTYPE" == "linux"* ]]; then
        cd "$installdir"
        docker exec -it tec-api sh -c "$(cat linuxhost-api)"
        docker exec -it tec-sistema sh -c "$(cat linuxhost-web)"
        cd "$work"
    fi

    if [[ "$OSTYPE" == "msys" ]]; then
        cd "$installdir"
        start dexec.bat http-api-xdebug $1
        start dexec.bat http-web-xdebug $1
        cd "$work"
    fi

    echo "Updating API"
    cd "$from/api"
    git checkout master &&
    git pull
    if [[ "$OSTYPE" == "msys" ]]; then
        cd "$installdir"
        start dexec.bat http-api-update
        cd "$work"
    else
        docker exec -it tec-api sh -c "cd /var/www/html && ssh -vvv git@bitbucket.org && COMPOSER_MEMORY_LIMIT=-1 composer update"
    fi
    echo ""

    echo "Updating Web"
    cd "$from/sistema/web"
    git checkout master &&
    git pull
    if [[ "$OSTYPE" == "msys" ]]; then
        cd "$installdir"
        start dexec.bat http-web-update
        cd "$work"
    else
        docker exec -it tec-sistema sh -c "cd /var/www/html && ssh -vvv git@bitbucket.org && composer update --ignore-platform-reqs"
    fi
    echo ""

#    echo "Updating Angular"
#    cd "$from/ng"
#    git checkout master &&
#    git pull &&
#    buildAngular
#    echo ""
}



case "$1" in

    bash)
        if [[ "$OSTYPE" == "msys" ]]; then
            winpty docker exec -it $2 //bin/bash
        else
            docker exec -i -t $2 /bin/bash
        fi
        ;;
    
    clone)
        cloneRepo api API
        cloneRepo sistema Web
        cloneRepo ng Angular
        ;;

    rebuild)
        cd "$installdir"
        docker compose down
        docker compose build
        cd "$work"
        ;;
    up)
        cd "$installdir"
        docker compose up -d
        cd "$work"
        ;;
    down)
        cd "$installdir"
        docker compose stop
        cd "$work"
        ;;
    restart)
        cd "$installdir"
        docker compose stop
        docker compose up -d
        cd "$work"
        ;;

    setup)
        $0 clone \
        && $0 rebuild \
        && $0 up \
        && updateAll $2
        cd "$work"
        ;;

    test)
        args="${@:3}"
        if [ "$2" == "api" ]; then
            if [[ "$OSTYPE" == "msys" ]]; then
                cd "$installdir"
                start dexec.bat http-api-test $args
                cd "$work"
            else
                docker exec -it tec-api sh -c "COMPOSER_PROCESS_TIMEOUT=3600 composer test -- $args"
            fi
        fi
        if [ "$2" == "ng" ]; then
            if [[ "$OSTYPE" == "msys" ]]; then
                cd "$installdir"
                start dexec.bat node-ng-test $args
                cd "$work"
            else
                docker exec -it node-ng sh -c "cd /app && npx ng test -- $args"
            fi
        fi
        ;;        


    *)
        echo ""
        echo "Commands available: ($OSTYPE)"
        echo ""
        echo "    clone                       - Clona os projetos API, SISTEMA e NG"
        echo "    setup                       - Sets up master branch for all containers"
        echo "    db <project> <arguments...> - Runs database utility for project"
        echo "    up                          - Inicia os containers"
        echo "    down                        - Para os containers"
        echo "    restart                     - Para os containers e inicia novamente"
        echo "    bash <image-name>           - Acessa o container pelo terminal"
        echo "    ng-build                    - Build NG project"
        echo "    ng-start                    - Starts NG project for development"
        echo ""
esac