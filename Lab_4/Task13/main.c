#include <stdio.h>
#include <stdlib.h>

// Функция для проверки, делится ли число на две своих последних цифры
int is_divisible_by_last_two_digits(int num) {
    // Получаем две последние цифры числа
    int last_two_digits = num % 100;
    
    // Если две последние цифры равны 0, то деление на 0 невозможно
    if (last_two_digits == 0) {
        return 0;
    }
    
    // Проверяем, делится ли число на две последние цифры
    return (num % last_two_digits == 0);
}

int main() {
    int n;
    
    printf("Введите число n: ");
    scanf("%d", &n);
    
    if (n < 1) {
        printf("n должно быть положительным числом.\n");
        return 1;
    }
    
    printf("Числа, не превосходящие %d и делящиеся на две своих последних цифры:\n", n);
    
    int count = 0;
    for (int i = 10; i <= n; i++) {
        if (is_divisible_by_last_two_digits(i)) {
            printf("%d ", i);
            count++;
            
            // Выводим по 10 чисел в строку для удобства чтения
            if (count % 10 == 0) {
                printf("\n");
            }
        }
    }
    
    printf("\n\nВсего найдено: %d чисел\n", count);
    
    return 0;
}