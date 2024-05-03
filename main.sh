#!/bin/bash

# This is a TO-DO application that can be controlled via the console, has a file database, and performs CRUD operations.
# It creates a folder named todos in the current directory and saves the to-dos in the format of todo_name.txt.
# Each txt file contains only the deadline information.

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
echo -e "${BLUE_COLOR}Welcome to the To-Do application!${WHITE_COLOR}"

while [ 0 ]
do
    echo "Please enter the number of the operation you want to perform!"
    echo "1) List To-Dos. 2) Add New To-Do. 3) Update To-Do. 4) Delete To-Do."

    read -r PROCESS_NUMBER

    case ${PROCESS_NUMBER} in
        1) 
            clear
            echo "---------------------"
            echo -e "${BLUE_COLOR}To-Do | Deadline${WHITE_COLOR}"
            echo "---------------------"

            ([ `printf *.txt` != '*.txt' ] || [ -f '*.txt' ])

            if [ $? != 0 ]; then
              echo -e "${RED_COLOR}No to-dos yet!${WHITE_COLOR}"
              echo "---------------------"
              continue
            fi

            i=1
            for entry in *; do
                echo "$i) ${entry:0:-4} | $(cat "$entry")"
                ((i++))
            done

            echo "---------------------"
            echo -e "${GREEN_COLOR}Total of $(($i-1)) to-dos.${WHITE_COLOR}"
            echo "---------------------"
            ;;
        2) 
            clear
            echo "Enter the name of the to-do."
            read -r TODO_NAME

            TODO_FILE_NAME=${TODO_NAME,,}".txt"

            if [ -e "$TODO_FILE_NAME" ]; then
                echo -e "${RED_COLOR}ERROR: This to-do already exists, try updating it.${WHITE_COLOR}"
                continue
            else
                touch "$TODO_FILE_NAME"
            fi

            echo "Enter the deadline for the to-do. (Month/Day/Year)"
            read -r INPUT_DEADLINE_DATE
            
            CheckIfDateIsValid "$INPUT_DEADLINE_DATE"
            if [ $? != 0 ]; then
              echo -e "${RED_COLOR}ERROR: Invalid date: [${INPUT_DEADLINE_DATE}]; try again.${WHITE_COLOR}"
            else
              echo "$INPUT_DEADLINE_DATE" > "$TODO_FILE_NAME"
            fi

            echo -e "${GREEN_COLOR}To-Do created successfully!${WHITE_COLOR}"
          ;;
        3) 
            clear
            echo "Enter the number of the to-do you want to update."
            read -r TODO_NUMBER_TO_UPDATE

            isTodoUpdated=1

            i=0
            for entry in *; do
                if [ "$i" -eq "$((TODO_NUMBER_TO_UPDATE-1))" ]; then
                    TODO_FILE_TO_UPDATE=$(basename "$entry")

                    echo "Current To-Do name: ${TODO_FILE_TO_UPDATE:0:-4}"
                    echo "Enter the new name."
                    read -r NEW_TODO_NAME

                    echo "If you want to change the deadline, enter it (Month/Day/Year), otherwise just press any key."
                    read -r NEW_TODO_DEADLINE_DATE
                    
                    if [[ $(echo $NEW_TODO_DEADLINE_DATE | tr -d ' ') != "" ]]; then
                        CheckIfDateIsValid "$NEW_TODO_DEADLINE_DATE"
                        if [ $? != 0 ]; then
                          echo -e "${RED_COLOR}ERROR: Invalid date: [${NEW_TODO_DEADLINE_DATE}]; try again.${WHITE_COLOR}"
                        else
                          echo "$NEW_TODO_DEADLINE_DATE" > "$TODO_FILE_TO_UPDATE"
                        fi
                    fi

                    mv "$TODO_FILE_TO_UPDATE" "$NEW_TODO_NAME.txt"
                    echo -e "${GREEN_COLOR}To-Do updated successfully!${WHITE_COLOR}"
                    isTodoUpdated=0
                    break
                fi
                ((i++))
            done

            if [ "$isTodoUpdated" -ne 0 ]; then
              echo -e "${RED_COLOR}ERROR: To-Do not found!${WHITE_COLOR}"
            fi
          ;;
        4) 
            clear
            echo "Enter the number of the to-do you want to delete."
            read -r TODO_NUMBER_TO_DELETE

            isTodoFound=1

            i=0
            for entry in *; do
                if [ "$i" -eq "$((TODO_NUMBER_TO_DELETE-1))" ]; then
                    TODO_FILE_TO_DELETE=$(basename "$entry")

                    echo "To-Do to be deleted: ${TODO_FILE_TO_DELETE:0:-4}"
                    echo "Press "y" to delete, "n" to cancel."
                    read -r INPUT_YES_OR_NO

                    isTodoFound=0

                    case $(echo $INPUT_YES_OR_NO | tr -d ' ') in
                        "y")
                            rm "$TODO_FILE_TO_DELETE"
                            echo -e "${GREEN_COLOR}To-Do deleted successfully!${WHITE_COLOR}"
                            ;;
                        "n")
                            echo "Deletion of the To-Do cancelled!"
                            ;;
                          *) 
                          echo -e "${RED_COLOR}ERROR: Invalid response!"
                          exit 1
                        ;;
                    esac
                fi
                ((i++))
            done

            if [ "$isTodoFound" -ne 0 ]; then
              echo -e "${RED_COLOR}ERROR: To-Do not found!${WHITE_COLOR}"
            fi
          ;;
        *) 
            clear
            echo -e "${RED_COLOR}ERROR: Invalid operation number!${WHITE_COLOR}"
            exit 1
          ;;
    esac
done
