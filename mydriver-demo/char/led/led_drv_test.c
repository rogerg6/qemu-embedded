#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "Usage: %s /dev/ledx on/off\n", argv[0]);
        return -1;
    }
    int         fd  = -1;
    const char *dev = argv[1];
    const char *op  = argv[2];

    fd = open(dev, O_RDWR);
    if (fd < 0) {
        perror("open");
        return -2;
    }

    if (strcmp(op, "on") == 0) {
        write(fd, "1", 1);
    } else if (strcmp(argv[2], "off") == 0) {
        write(fd, "0", 1);
    } else {
        fprintf(stderr, "Unsupport operation: %s\n", op);
        return -3;
    }

    close(fd);
    return 0;
}