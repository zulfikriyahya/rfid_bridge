# Wiring Documentation — RFID HID Emulator

Dokumen ini mencakup wiring untuk dua varian board:
1. DOIT ESP32 Devkit V1 (ESP32 klasik)
2. ESP32-C3 Super Mini

Modul yang digunakan: **RC522 (MFRC522) RFID Reader** + **Buzzer aktif**

---

## 1. DOIT ESP32 Devkit V1

### Pin Konfigurasi
| Fungsi | GPIO |
|--------|------|
| SS/SDA (RC522) | GPIO 5 |
| RST (RC522) | GPIO 27 |
| SCK | GPIO 18 |
| MISO | GPIO 19 |
| MOSI | GPIO 23 |
| Buzzer | GPIO 4 |

### Tabel Wiring RC522 → ESP32 Devkit V1
| RC522 Pin | ESP32 GPIO | Keterangan |
|-----------|-----------|------------|
| SDA (SS)  | GPIO 5    | Chip Select |
| SCK       | GPIO 18   | SPI Clock (VSPI default) |
| MOSI      | GPIO 23   | SPI Data Out |
| MISO      | GPIO 19   | SPI Data In |
| IRQ       | *(NC)*    | Tidak dipakai |
| GND       | GND       | Ground |
| RST       | GPIO 27   | Reset |
| 3.3V      | 3.3V      | **Wajib 3.3V, jangan 5V** |

### Wiring Buzzer
| Buzzer Pin | ESP32 GPIO |
|-----------|-----------|
| Positif (+) | GPIO 4 |
| Negatif (–) | GND |

### Diagram (teks)
```
RC522          ESP32 Devkit V1
-----          ---------------
SDA/SS   -->   GPIO 5
SCK      -->   GPIO 18
MOSI     -->   GPIO 23
MISO     -->   GPIO 19
IRQ      -->   (NC)
GND      -->   GND
RST      -->   GPIO 27
3.3V     -->   3.3V

Buzzer +  -->  GPIO 4
Buzzer -  -->  GND
```

---

## 2. ESP32-C3 Super Mini

### Pin Konfigurasi
| Fungsi | GPIO |
|--------|------|
| SS/SDA (RC522) | GPIO 7 |
| RST (RC522) | GPIO 10 |
| SCK | GPIO 4 |
| MISO | GPIO 5 |
| MOSI | GPIO 6 |
| Buzzer | GPIO 3 |

### Tabel Wiring RC522 → ESP32-C3 Super Mini
| RC522 Pin | ESP32-C3 GPIO | Keterangan |
|-----------|---------------|------------|
| SDA (SS)  | GPIO 7        | Chip Select |
| SCK       | GPIO 4        | SPI Clock |
| MOSI      | GPIO 6        | SPI Data Out |
| MISO      | GPIO 5        | SPI Data In |
| IRQ       | *(NC)*        | Tidak dipakai |
| GND       | GND           | Ground |
| RST       | GPIO 10       | Reset |
| 3.3V      | 3.3V          | **Wajib 3.3V, jangan 5V** |

### Wiring Buzzer
| Buzzer Pin | ESP32-C3 GPIO |
|-----------|---------------|
| Positif (+) | GPIO 3 |
| Negatif (–) | GND |

### Diagram (teks)
```
RC522          ESP32-C3 Super Mini
-----          -------------------
SDA/SS   -->   GPIO 7
SCK      -->   GPIO 4
MOSI     -->   GPIO 6
MISO     -->   GPIO 5
IRQ      -->   (NC)
GND      -->   GND
RST      -->   GPIO 10
3.3V     -->   3.3V

Buzzer +  -->  GPIO 3
Buzzer -  -->  GND
```

---

## Catatan Penting (Berlaku untuk Kedua Board)

1. **Tegangan modul RC522 wajib 3.3V.** Jangan sambungkan ke pin 5V, karena bisa merusak modul dan/atau ESP32.
2. **Pin IRQ pada RC522 tidak dipakai** dalam project ini (polling based, bukan interrupt based), jadi boleh dibiarkan tidak tersambung (NC / not connected).
3. **Kabel SPI sebaiknya pendek** (idealnya < 20 cm) untuk menghindari noise yang bisa menyebabkan pembacaan UID tidak stabil.
4. Untuk **ESP32-C3 Super Mini**, hindari pin strapping (GPIO 2, 8, 9) untuk fungsi yang aktif saat boot — pin-pin di atas (3, 4, 5, 6, 7, 10) sudah aman dari isu tersebut.
5. **USB-to-Serial chip berbeda** antar board — penting untuk driver di komputer:
   - DOIT ESP32 Devkit V1 → chip **CP2102/CP210x** (Silicon Labs), driver: [https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers](https://www.silabs.com/developers/usb-to-uart-bridge-vcp-drivers)
   - ESP32-C3 Super Mini → biasanya native USB (CDC) atau chip **CH9102**, umumnya plug-and-play di OS modern, tapi kalau tidak terdeteksi, cari driver CH340/CH9102 series.

---

## Board Selection di Arduino IDE

| Board Fisik | Pilihan di Arduino IDE |
|-------------|------------------------|
| DOIT ESP32 Devkit V1 | `ESP32 Dev Module` |
| ESP32-C3 Super Mini | `ESP32C3 Dev Module` |

Pastikan pilihan board sesuai sebelum compile & upload, karena pin mapping antar board berbeda total (lihat tabel di atas).
