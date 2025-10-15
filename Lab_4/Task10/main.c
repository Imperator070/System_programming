#include <stdio.h>
#include <string.h>

#define MAX 5

int main() {
    char correct_password[50];
    char input[50];
    int attempts = 0;
    scanf("%s", correct_password);
    while (attempts < MAX) {
        scanf("%s", input);

        if (strcmp(input, correct_password) == 0) {
            printf("Вошли\n");
            return 0;
        } else {
            printf("Неверный пароль\n");
            attempts++;
        }
    }

    printf("Неудача\n");
    return 1;
}