import numpy as np
import cv2
import os
import csv
import matplotlib.pyplot as plt

trouble = False
save = True

directory = os.getcwd()
file = os.path.join(directory, 'lineage.png')

image = cv2.imread(file)
h, w, c = image.shape[:3]

gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

dens = []
dens_out =[]
for i in range(h):
    temp = 0
    span = 0
    for j in range(w):
        if gray[i, j] == 0:
            span += 1
        else:
            if span > 2:
                temp += 1
            else:
                image[i, j - 2] = (255, 255, 255)
                image[i, j - 1] = (255, 255, 255)
            span = 0
    dens.append(temp)
    dens_out.append([i, (i - 20) / 26.222, temp])

if save:
    cv2.imwrite('div_only.png', image)

with open('out.csv', 'w+', newline='') as file:
    writer = csv.writer(file)
    writer.writerows(dens_out)

plt.figure(1)
plt.subplot(211)    
plt.plot(dens)
print(sum(dens) / 2)

dens_smooth = []
dens_smooth_out = []
smooth = 20
kernel_sum = 0
for j in range(round(-smooth / 2), round(smooth / 2)):
    if j != 0:
        kernel_sum += abs(1 / j)
    else:
        kernel_sum += 1
for i in range(round(smooth / 2), len(dens) - round(smooth / 2)):
    temp = 0
    for j in range(round(-smooth / 2), round(smooth / 2)):
        if j != 0:
            temp += dens[i + j] * abs(1 / j)
        else:
            temp += dens[i]
    dens_smooth.append(temp / kernel_sum)
    dens_smooth_out.append([i, (i - 20) / 26.222, temp / kernel_sum])

with open('smooth_out.csv', 'w+', newline='') as file:
    writer = csv.writer(file)
    writer.writerows(dens_smooth_out)

plt.subplot(212)   
plt.plot(dens_smooth)

print(sum(dens_smooth) / 2)
    
