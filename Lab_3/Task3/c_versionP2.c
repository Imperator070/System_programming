#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    int a = atoi(argv[1]);
    int b = atoi(argv[2]);
    int c = atoi(argv[3]);
    int result = (((((a/b)-a)+c)/c)*b);
    printf(" %d\n", result);
    return 0;
}
