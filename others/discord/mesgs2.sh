person[0]="Danilo"
person[1]="Marco"
person[2]="Erick"
person[3]="Max"

size=${#person[@]}
index=$(($RANDOM % $size))
PERSON=${person[$index]}

food[0]="Pastel"
food[1]="Pizza"
food[2]="Sushi"
food[3]="Lanche"

size=${#food[@]}
index=$(($RANDOM % $size))
FOOD=${food[$index]}

mesg[0]="Caga Danilo"

export mesg;
