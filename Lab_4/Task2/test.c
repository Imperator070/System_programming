#include <stdio.h>

int main() {
    int n;
    int sum = 0;
    int sign = 1; // Начинаем с положительного знака
    
    printf("Введите значение n: ");
    scanf("%d", &n);
    
    for (int i = 1; i <= n; i++) {
        sum += sign * (i * i); // i² = i * i
        sign = -sign; // Меняем знак для следующего члена
    }
    
    printf("Сумма ряда для n = %d: %d\n", n, sum);
    
    return 0;
}