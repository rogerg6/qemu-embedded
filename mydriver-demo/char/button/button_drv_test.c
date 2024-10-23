/**
 * @brief: read button%d's gpio value
 */
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>

int main(int argc, char *argv[]) {
  if (argc < 2) {
    fprintf(stderr, "Usage: %s /dev/buttonx\n", argv[0]);
    return -1;
  }
  int fd = -1;
  const char *dev = argv[1];
  const char *op = argv[2];

  fd = open(dev, O_RDWR);
  if (fd < 0) {
    perror("open");
    return -2;
  }

  char level;

  if (read(fd, &level, 1) == 1) {
    printf("Read level = %d\n", level);
  } else {
    fprintf(stderr, "Read error");
  }

  close(fd);
  return 0;
}