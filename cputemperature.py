import os
import time


def measure_temp():
    temp = os.popen("vcgencmd measure_temp").readline()
    return (temp.replace("temp=","").strip())


def main():
    while True:
        print(measure_temp())
        time.sleep(1)


if __name__ == "__main__":
    main()
