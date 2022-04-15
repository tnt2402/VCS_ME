#include <stdio.h>
int fibo(int n) {
    if (n < 2) return n;
    return fibo(n-1)+fibo(n-2);
}
int main() {
    int n = 3;
    printf("%d", fibo(n));
    return 0;

}
