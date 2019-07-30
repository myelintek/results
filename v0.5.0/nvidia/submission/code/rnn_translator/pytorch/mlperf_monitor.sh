#!/bin/bash
#works only if there is one mlperf container
#get_docker_id()
#{
#    id=$(docker ps | awk '/mlperf-nvidia/ {print $1}')
#}

id=$1

run_zombie_monitor()
{
    check=$(docker ps | grep $id)
    while [ ! -z "$check" ]
    do
        n_zombies=$(docker exec $id ps axo pid=,stat= | awk '$2~/^Z/ { print }'| wc -l)
        num_process=$(docker exec $id ps aux | wc -l)
        if  [ $num_process -lt 4 ]  
        then
            echo $num_process
            docker exec $id ps aux
            sleep 300s
            num_process=$(docker exec $id ps aux | wc -l)
            if [ $num_process -lt 4 ]
            then
                docker exec $id ps aux
                docker stop $id
                echo "No processes in container"
            fi
        fi

        if  [ $n_zombies -ne 0 ] && [ ! -z "$n_zombies" ] 
        then
            echo "$n_zombies zombie in $id"
            echo "$num_process in $id"
            sleep 60s
            n_zombies=$(docker exec $id ps axo pid=,stat= | awk '$2~/^Z/ { print }'| wc -l)
            docker exec $id ps axo pid=,stat= | awk '$2~/^Z/ { print }'
            if [ $n_zombies -ne 0 ] && [ ! -z "$n_zombies" ] 
            then
                echo "Zombie alert in container $id"
                docker stop $id
            fi
        fi
        sleep 30s
        check=$(docker ps | grep $id)
    done
}

run_zombie_monitor
echo "Stop Monitor"
