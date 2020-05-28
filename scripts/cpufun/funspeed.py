#!/usr/bin/python
# -*- coding: utf-8 -*-

import RPi.GPIO as GPIO                     # Импортируем библиотеку по работе с GPIO
import os, sys, traceback                       # Импортируем библиотеки для обработки исключений

from time import sleep                      # Импортируем библиотеку для работы со временем
from re import findall                      # Импортируем библиотеку по работе с регулярными выражениями
from subprocess import check_output         # Импортируем библиотеку по работе с внешними процессами

def get_temp():
    temp = check_output(["vcgencmd","measure_temp"]).decode()    # Выполняем запрос температуры
    temp = float(findall('\d+\.\d+', temp)[0])                   # Извлекаем при помощи регулярного выражения значение температуры из строки "temp=47.8'C"
    return(temp)                            # Возвращаем результат

def map(x, inMin, inMax, outMin, outMax):
    if x < inMin:
        return outMin
    elif x > inMax:
        return outMax
    result = (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
    return round(result)

try:
    tempOn = 60                             # Температура включения кулера
    controlPin = 14                         # Пин отвечающий за управление
    pinState = False                        # Актуальное состояние кулера
    pwmStopped = True
    if len(sys.argv) > 1:
        directory = sys.argv[1]
    else:
        directory = "/tmp"
    print directory
    if not os.path.exists(directory):
        os.makedirs(directory)
    
    # === Инициализация пинов ===
    GPIO.setmode(GPIO.BCM)                  # Режим нумерации в BCM
    GPIO.setup(controlPin, GPIO.OUT, initial=0) # Управляющий пин в режим OUTPUT
    pwm = GPIO.PWM(controlPin, 500)

    while True:                             # Бесконечный цикл запроса температуры
        temp = get_temp()                   # Получаем значение температуры
        f = open(directory + "/cpu.temp", "w")
        f.write("%d C" % temp)
        f.close()

        pwmValue = map(temp, 55, 70, 35, 100)
        f = open(directory + "/cpu.fun", "w")
        if temp < 50 and False == pwmStopped:
            pwm.stop();
            f.write("0")
            pwmStopped = True
        elif temp > 55 and True == pwmStopped:
            f.write("%d" % pwmValue)
            pwm.start(pwmValue)
            pwmStopped = False
        elif False == pwmStopped:
            f.write("%d" % pwmValue)
            pwm.ChangeDutyCycle(pwmValue)
        else:
            f.write("0")
        f.close()

        print(str(temp) + "  " + str(pwmValue)) # Выводим температуру в консоль
        sleep(1)                            # Пауза - 1 секунда

except KeyboardInterrupt:
    # ...
    print("Exit pressed Ctrl+C")            # Выход из программы по нажатию Ctrl+C
except:
    # ...
    print("Other Exception")                # Прочие исключения
    print("--- Start Exception Data:")
    traceback.print_exc(limit=2, file=sys.stdout) # Подробности исключения через traceback
    print("--- End Exception Data:")
finally:
    print("CleanUp")                        # Информируем о сбросе пинов
    GPIO.cleanup()                          # Возвращаем пины в исходное состояние
    print("End of program")                 # Информируем о завершении работы программы
