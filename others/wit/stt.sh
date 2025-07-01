export TOKEN=$sec_WIT_TOKEN
FILE=$1

curl -XPOST 'https://api.wit.ai/speech?v=20170307' \
   -i -L \
   -H "Authorization: Bearer $TOKEN" \
   -H "Content-Type: audio/wav" \
   --data-binary "@$FILE"
