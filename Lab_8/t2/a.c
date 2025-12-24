#include <stdio.h>
#include <math.h>

double compute_series(double x, double eps, int *n) {
    double sum = 0.0;
    double term;
    double x_power = x;  // текущая степень x
    double x4 = x*x*x*x; // x^4
    int i = 0;

    // Первый член: x^1/1 = x
    term = x;

    while (fabs(term) >= eps) {
        sum += term;
        i++;

        // Вычисляем следующую степень: умножаем на x^4
        x_power *= x4;

        // Вычисляем новый член: x_power / (4i+1)
        term = x_power / (4*i + 1);

        // Защита от бесконечного цикла
        if (i > 10000) break;
    }

    *n = i;
    return sum;
}

int main() {
    double x, eps;
    int n;

    printf("Введите x (|x| < 1): ");
    scanf("%lf", &x);

    printf("Введите точность: ");
    scanf("%lf", &eps);

    if (fabs(x) >= 1.0) {
        printf("Ошибка: |x| должен быть меньше 1\n");
        return 1;
    }

    double result = compute_series(x, eps, &n);

    printf("\nРезультаты:\n");
    printf("x = %.6f\n", x);
    printf("Точность = %g\n", eps);
    printf("Количество членов = %d\n", n);
    printf("Сумма ряда = %.10f\n", result);

    return 0;
}
