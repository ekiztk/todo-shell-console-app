#!/bin/bash

# Konsol üzerinden kontrol edilebilen, dosya veritabanına sahip ve CRUD işlemleri yapılabilen TO-DO uygulamasıdır.
# Çalıştırıldığı dizinde todos isimli bir klasör oluşturur ve yapılacakları yapılacak_isim.txt dosyası formatında kayıt eder.
# Her txt dosyası içinde sadece son tarih bilgisi bulunur.

GREEN_COLOR='\033[0;32m'
RED_COLOR='\033[0;31m'
BLUE_COLOR='\033[0;34m'
WHITE_COLOR='\033[0;37m'

CheckIfDateIsValid () {
  date -d "$1" > /dev/null 2>&1
  if [ $? != 0 ]; then
    return 1
  else
    return 0
  fi
}

FILE_NAME="/todos"
FILE_DIR="$(pwd)"$FILE_NAME

if [ ! -d "$FILE_DIR" ]; then
    mkdir "$FILE_DIR"  
fi

cd "$FILE_DIR"
echo -e "${BLUE_COLOR}Yapılacaklar uygulamasına hoşgeldiniz!${WHITE_COLOR}"

while [ 0 ]
do
    echo "Lütfen yapmak istediğiniz işlem numarası giriniz!"
    echo "1) Yapılacakları listele. 2) Yeni yapılacak ekle. 3) Yapılacak güncelle. 4) Yapılacak sil."

    read -r PROCESS_NUMBER

    case ${PROCESS_NUMBER} in
        1) 
            clear
            echo "---------------------"
            echo -e "${BLUE_COLOR}Yapılacak | Son Tarih${WHITE_COLOR}"
            echo "---------------------"

            ([ `printf *.txt` != '*.txt' ] || [ -f '*.txt' ])

            if [ $? != 0 ]; then
              echo -e "${RED_COLOR}Hiç yapılacak yok!${WHITE_COLOR}"
              echo "---------------------"
              continue
            fi

            i=1
            for entry in *; do
                echo "$i) ${entry:0:-4} | $(cat "$entry")"
                ((i++))
            done

            echo "---------------------"
            echo -e "${GREEN_COLOR}Toplam $(($i-1)) adet yapılacak var.${WHITE_COLOR}"
            echo "---------------------"
            ;;
        2) 
            clear
            echo "Yapılacak ismi girin."
            read -r TODO_NAME

            TODO_FILE_NAME=${TODO_NAME,,}".txt"

            if [ -e "$TODO_FILE_NAME" ]; then
                echo -e "${RED_COLOR}HATA: Bu yapılacak zaten tanımlı, güncellemeyi deneyin.${WHITE_COLOR}"
                continue
            else
                touch "$TODO_FILE_NAME"
            fi

            echo "Yapılacak için son tarihi girin. (Ay/Gün/Yıl)"
            read -r INPUT_DEADLINE_DATE
            
            CheckIfDateIsValid "$INPUT_DEADLINE_DATE"
            if [ $? != 0 ]; then
              echo -e "${RED_COLOR}HATA: Geçersiz tarih: [${INPUT_DEADLINE_DATE}]; tekrar deneyin.${WHITE_COLOR}"
            else
              echo "$INPUT_DEADLINE_DATE" > "$TODO_FILE_NAME"
            fi

            echo -e "${GREEN_COLOR}Yapılacak başarıyla oluşturuldu!${WHITE_COLOR}"
          ;;
        3) 
            clear
            echo "Güncellemek istediğiniz yapılacak numarasını girin."
            read -r TODO_NUMBER_TO_UPDATE

            isTodoUpdated=1

            i=0
            for entry in *; do
                if [ "$i" -eq "$((TODO_NUMBER_TO_UPDATE-1))" ]; then
                    TODO_FILE_TO_UPDATE=$(basename "$entry")

                    echo "Mevcut Yapılacak isimi: ${TODO_FILE_TO_UPDATE:0:-4}"
                    echo "Yeni isimi giriniz."
                    read -r NEW_TODO_NAME

                    echo "Eğer son tarihi değiştirmek istiyorsanız girin (Ay/Gün/Yıl), yoksa sadece herhangi bir tuşa basın."
                    read -r NEW_TODO_DEADLINE_DATE
                    
                    if [[ $(echo $NEW_TODO_DEADLINE_DATE | tr -d ' ') != "" ]]; then
                        CheckIfDateIsValid "$NEW_TODO_DEADLINE_DATE"
                        if [ $? != 0 ]; then
                          echo -e "${RED_COLOR}HATA: Geçersiz tarih: [${NEW_TODO_DEADLINE_DATE}]; tekrar deneyin.${WHITE_COLOR}"
                        else
                          echo "$NEW_TODO_DEADLINE_DATE" > "$TODO_FILE_TO_UPDATE"
                        fi
                    fi

                    mv "$TODO_FILE_TO_UPDATE" "$NEW_TODO_NAME.txt"
                    echo -e "${GREEN_COLOR}Yapılacak başarıyla güncellendi!${WHITE_COLOR}"
                    isTodoUpdated=0
                    break
                fi
                ((i++))
            done

            if [ "$isTodoUpdated" -ne 0 ]; then
              echo -e "${RED_COLOR}HATA: Yapılacak bulunamadı!${WHITE_COLOR}"
            fi
          ;;
        4) 
            clear
            echo "Silmek istediğiniz yapılacak numarasını girin."
            read -r TODO_NUMBER_TO_DELETE

            isTodoFound=1

            i=0
            for entry in *; do
                if [ "$i" -eq "$((TODO_NUMBER_TO_DELETE-1))" ]; then
                    TODO_FILE_TO_DELETE=$(basename "$entry")

                    echo "Silinecek Yapılacak isimi: ${TODO_FILE_TO_DELETE:0:-4}"
                    echo "Silmek için "y", iptal için "n" tuşuna basın."
                    read -r INPUT_YES_OR_NO

                    isTodoFound=0

                    case $(echo $INPUT_YES_OR_NO | tr -d ' ') in
                        "y")
                            rm "$TODO_FILE_TO_DELETE"
                            echo -e "${GREEN_COLOR}Yapılacak başarıyla silindi!${WHITE_COLOR}"
                            ;;
                        "n")
                            echo "Yapılacak silinmesi iptal edildi!"
                            ;;
                          *) 
                          echo -e "${RED_COLOR}HATA: Geçersiz cevap!"
                          exit 1
                        ;;
                    esac
                fi
                ((i++))
            done

            if [ "$isTodoFound" -ne 0 ]; then
              echo -e "${RED_COLOR}HATA: Yapılacak bulunamadı!${WHITE_COLOR}"
            fi
          ;;
        *) 
            clear
            echo -e "${RED_COLOR}HATA: Geçersiz işlem numarası!${WHITE_COLOR}"
            exit 1
          ;;
    esac
done