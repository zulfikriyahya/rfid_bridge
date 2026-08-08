#include <SPI.h>
#include <MFRC522.h>

#define SS_PIN 5
#define RST_PIN 27
#define BUZZER_PIN 4

MFRC522 rfid(SS_PIN, RST_PIN);

void beepSuccess()
{
  tone(BUZZER_PIN, 2000);
  delay(120);
  noTone(BUZZER_PIN);
}

void beepStartup()
{
  tone(BUZZER_PIN, 1800);
  delay(80);
  noTone(BUZZER_PIN);
  delay(60);
  tone(BUZZER_PIN, 2000);
  delay(80);
  noTone(BUZZER_PIN);
}

void setup()
{
  Serial.begin(115200);
  pinMode(BUZZER_PIN, OUTPUT);
  SPI.begin();
  rfid.PCD_Init();
  beepStartup();
  Serial.println("RFID Reader siap. Tempelkan kartu...");
}

void loop()
{
  if (!rfid.PICC_IsNewCardPresent())
  {
    return;
  }
  if (!rfid.PICC_ReadCardSerial())
  {
    return;
  }

  uint32_t uidValue;
  if (rfid.uid.size >= 4)
  {
    uidValue = ((uint32_t)rfid.uid.uidByte[3] << 24) | ((uint32_t)rfid.uid.uidByte[2] << 16) | ((uint32_t)rfid.uid.uidByte[1] << 8) | rfid.uid.uidByte[0];
  }
  else
  {
    uidValue = ((uint32_t)rfid.uid.uidByte[0] << 8) | rfid.uid.uidByte[1];
  }

  char buf[11];
  sprintf(buf, "%010lu", (unsigned long)uidValue);
  Serial.println(buf);
  beepSuccess();

  rfid.PICC_HaltA();
  rfid.PCD_StopCrypto1();
  delay(150);
}
