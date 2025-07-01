MESG_DATE=$(date +%H)

function getRandomName() {

	person[0]="Danilo"
	person[1]="Marco"
	person[2]="Erick"
	person[3]="Max"

	size=${#person[@]}
	index=$(($RANDOM % $size))
	echo ${person[$index]}
}

function getRandomFood() {

	food[0]="Pastel"
	food[1]="Pizza"
	food[2]="Sushi"
	food[3]="Lanche"

	size=${#food[@]}
	index=$(($RANDOM % $size))
	echo ${food[$index]}
}

NAME=$(getRandomName)
FOOD=$(getRandomFood)

i=0

mesg[((i++))]="Sai do grupo e ninguem fala nada agora"

export mesg;

# EOF
