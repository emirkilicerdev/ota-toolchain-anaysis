# MSP430 `.z1` / `.sky` / `ARM M4F(CC1352R)` / `cooja-native` Platformları için Üretilmiş Firmware’ler Üzerinde Yapılabilecek Analiz Türleri Kontrol Listesi

---
##### (* ARM Mimarisinde derlenmiş firmware analizi yapmak isteyen gruplar MSP430 Toolchain yanında ARM-Toolchain araçlarını da indirip, kullanmalıdırlar.)

``` bash
  $ wget https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2
  $ tar -xjf gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2
```
---
##### ** Analiz etmeniz için farklı platformlarda oluşturulmuş örnek firmware arşivi bil.omu drive linki için [tıklayınız](https://drive.google.com/file/d/1oLrZWPmDyuznWe5qS7zOsfSyyyPcQbBG/view?usp=sharing) .


---

# BIL 304 — Araştırma İş Parçacığı Teslimatı

> Bu repo, BIL 304 dönem projesinin **2. Bölümü (Araştırma Süreci)** kapsamında
> hazırlanmıştır. Şablon repodan fork'lanmış, her 23 analiz başlığının altına gerçek
> firmware analiz sonuçları **ve yorumları** eklenmiştir.
>
> **Önemli:** Hocanın kuralı gereği yalnızca komut çıktısı kopyalanmamış; her çıktının
> altına **"💡 Yorum"** paragrafı eklenerek araç zincirinin amacı ve çıktının firmware
> rolü açısından anlamı açıklanmıştır.

## 📋 Analiz Edilen 16 Firmware

Tüm dosyalar `firmware-samples/` klasöründedir. Hocanın `Cooja-Images.zip` arşivindeki
13 örnek + kendi ürettiğimiz 3 firmware (`own-` önekli, Part 1 OTA projesinden):

| # | Firmware | Platform | Mimari | Kaynak |
|---|----------|----------|--------|--------|
| 1 | `base-demo.simplelink` | CC1352R LaunchPad | ARM Cortex-M4F | Zip |
| 2 | `hardworker.z1` | Z1 mote | MSP430 | Zip |
| 3 | `hello-world.sky` | Sky mote | MSP430 | Zip |
| 4 | `hello-world.z1` | Z1 mote | MSP430 | Zip |
| 5 | `mtype5756516.cooja` | Cooja-native | x86-64 | Zip |
| 6 | `nullnet-broadcast.z1` | Z1 mote | MSP430 | Zip |
| 7 | `nullnet-unicast-u50.sky` | Sky mote | MSP430 | Zip |
| 8 | `nullnet-unicast.sky` | Sky mote | MSP430 | Zip |
| 9 | `nullnet-unicast.z1` | Z1 mote | MSP430 | Zip |
| 10 | `nullnet-unicast_eleco.sky` | Sky mote | MSP430 | Zip |
| 11 | `udp-client.sky` | Sky mote | MSP430 | Zip |
| 12 | `udp-client.z1` | Z1 mote | MSP430 | Zip |
| 13 | `udp-server.sky` | Sky mote | MSP430 | Zip |
| 14 | `own-new-firmware.z1` | Z1 mote | MSP430 | Kendi (OTA payload) |
| 15 | `own-udp-client.z1` | Z1 mote | MSP430 | Kendi (OTA gönderici) |
| 16 | `own-udp-server.z1` | Z1 mote | MSP430 | Kendi (OTA alıcı) |

## ⚙️ Analiz Yöntemi

Analizler `run-analysis.sh` betiği ile toplu olarak üretilmiştir. Betik her dosyanın
uzantısına bakıp doğru araç zincirini seçer:

| Uzantı | Platform | Araç ön eki |
|--------|----------|-------------|
| `.z1` / `.sky` | MSP430 | `msp430-*` (Contiki-NG Docker imajında hazır) |
| `.simplelink` | ARM Cortex-M4F | `arm-none-eabi-*` (GNU Arm Embedded 9-2020-q2) |
| `.cooja` | x86-64 native | standart GNU binutils (`readelf`, `objdump`...) |

Ham çıktılar `analysis-output/` klasörüne dökülür (her firmware için 10 dosya: ELF
header, section/segment/symbol tabloları, size, nm, objdump, strings, vektörler).

---

# 1. Binary Kimlik Analizi

* Hedef platform analizi (`.z1` / `.sky` / `ARM M4F(CC1352R)` / `cooja-native`)
* MSP430 mimari tipi
* ELF format bilgisi
* Endianness nedir ve Endianness bilgisi
* Entry point adresi
* ABI nedir ve ABI bilgisi
* Compiler izi
* Toolchain versiyonu
* Optimization level tahmini
* Debug symbol var/yok analizi

Araçlar:

* `msp430-readelf`
* `msp430-objdump`
* `msp430-strings`
* `Ve üstteki araçların ARM versiyonları...`

## 🔬 Analiz Bulguları

Kullanılan komut: `readelf -h <firmware>` (ELF başlığını okur).

| Firmware | ELF Sınıfı | Mimari | Tür | Entry | Endian |
|----------|-----------|--------|-----|-------|--------|
| `*.z1` (8 dosya) | ELF32 | TI MSP430 | EXEC | `0x3100` | little |
| `*.sky` (6 dosya) | ELF32 | TI MSP430 | EXEC | `0x4000` | little |
| `base-demo.simplelink` | ELF32 | ARM | EXEC | `0x6751` | little |
| `mtype5756516.cooja` | ELF64 | x86-64 (AMD64) | DYN | `0x14b00` | little |

`base-demo.simplelink` ELF başlığından (kısaltılmış):
```
Class:    ELF32         Machine:  ARM
Type:     EXEC          Entry point address:  0x6751
Flags:    0x5000200, Version5 EABI, soft-float ABI
```

**Compiler / toolchain izleri** (`.comment` ve `strings` çıktısından):

| Firmware | Derleyici izi | Contiki-NG sürümü |
|----------|---------------|-------------------|
| `own-*.z1`, `nullnet-unicast.z1` | msp430-gcc | `v4.8-625` |
| `hardworker.z1`, `hello-world.sky` | msp430-gcc | `v4.9-639` |
| `base-demo.simplelink` | `GCC ARM 9.3.1 20200408` | `v4.9-639` |
| `mtype5756516.cooja` | `GCC Ubuntu 11.3.0` | `v4.9-544` |

💡 **Yorum:** `readelf -h` bir firmware'in **kimlik kartıdır**. Dört farklı platform
net biçimde ayrıştı: `.z1`/`.sky` dosyaları **16-bit MSP430** mikrodenetleyicisi için
ELF32; `base-demo.simplelink` **32-bit ARM Cortex-M4F** (CC1352R) için ELF32;
`mtype5756516.cooja` ise PC üzerinde koşan **64-bit x86 paylaşımlı kütüphane** (DYN
tipi — Cooja simülatörü bunu `.so` gibi `dlopen` ile yükler). Tüm platformlar
**little-endian** (düşük anlamlı byte önce). Entry point farkları platformun bellek
haritasını yansıtır: MSP430 Z1 kodu `0x3100`'den, Sky `0x4000`'den, ARM `0x6751`'den
başlar. ARM dosyasındaki **`soft-float ABI`** bayrağı önemli: derleyici donanım FPU'su
yerine yazılım kayan-nokta çağrı uzlaşımı seçmiş. Tüm dosyalarda `.debug_*` bölümleri
bulunduğundan bunlar **debug build**'dir ve Contiki-NG'nin standart `-Os` (boyut)
optimizasyonu ile derlenmiştir.

---

# 2. Bellek Kullanım Analizi

* Flash, RAM, Stack, Heap anlamları
* Flash kullanım miktarı
* RAM kullanım miktarı
* `.text` boyutu
* `.data` boyutu
* `.bss` boyutu
* Stack kullanım tahmini
* Heap var/yok analizi
* Section dağılımı
* Memory map analizi
* Büyük veri yapılarının tespiti

Araçlar:

* `msp430-size`
* `msp430-readelf`
* `msp430-nm`
* `Ve üstteki araçların ARM versiyonları...`

## 🔬 Analiz Bulguları

Kullanılan komut: `size <firmware>` — `text`/`data`/`bss` bölüm boyutlarını verir.

| Firmware | text | data | bss | **Flash** (text+data) | **RAM** (data+bss) |
|----------|------|------|-----|----------------------|--------------------|
| `nullnet-broadcast.z1` | 17866 | 166 | 2240 | 18 032 | 2 406 |
| `nullnet-unicast.z1` | 28097 | 2488 | 2632 | 30 585 | 5 120 |
| `hello-world.z1` | 41512 | 328 | 5676 | 41 840 | 6 004 |
| `udp-client.z1` | 42542 | 336 | 5888 | 42 878 | 6 224 |
| `own-udp-client.z1` | 49545 | 390 | 5922 | 49 935 | 6 312 |
| `own-udp-server.z1` | 50998 | 390 | 6042 | 51 388 | 6 432 |
| `own-new-firmware.z1` | 71715 | 336 | 5706 | 72 051 | 6 042 |
| `hardworker.z1` | 73564 | 374 | 5698 | 73 938 | 6 072 |
| `hello-world.sky` | 42237 | 324 | 6714 | 42 561 | 7 038 |
| `udp-client.sky` | 43386 | 330 | 7024 | 43 716 | 7 354 |
| `nullnet-unicast.sky` | 29171 | 4426 | 3086 | 33 597 | 7 512 |
| `base-demo.simplelink` (ARM) | 71393 | 1408 | 12968 | 72 801 | 14 376 + heap |
| `mtype5756516.cooja` (x86) | 324415 | 9488 | 292376 | — | — |

Donanım sınırlarına oturma (yaklaşık):
```
Z1  (MSP430F2617): 92 KB Flash / 8 KB RAM
Sky (MSP430F1611): 48 KB Flash / 10 KB RAM
CC1352R          : 352 KB Flash / 80 KB SRAM
```

💡 **Yorum:** `size` aracı firmware'in **donanıma sığıp sığmayacağını** gösterir.
**`text`** = makine kodu + sabitler → kalıcı olarak **Flash**'ta durur. **`data`** =
başlangıç değeri olan global değişkenler; ilk değerleri Flash'ta saklanır, açılışta
RAM'e kopyalanır (yani hem Flash hem RAM tüketir). **`bss`** = sıfır başlangıçlı
değişkenler; Flash'ta yer kaplamaz, açılışta RAM'de sıfırlanır. **Stack ve Heap**
`size` çıktısında görünmez çünkü çalışma anında ayrılırlar — `bss` üstündeki boş RAM'i
paylaşırlar. Karşılaştırma çarpıcı: `nullnet-broadcast.z1` yalnızca 18 KB Flash
kullanırken `hardworker.z1` 74 KB kullanıp Z1'in 92 KB'lık flash'ının %80'ini doldurur.
**Büyük veri yapısı tespiti:** `nullnet-unicast.sky`'ın `data=4426` byte'ı diğer
nullnet sürümlerinden ~25 kat büyük — firmware içinde gömülü büyük bir sabit tablo
olduğuna işaret eder. `mtype5756516.cooja`'nın 292 KB `bss`'i ise yanıltıcı değildir:
PC'de çalıştığı için RAM kısıtı yoktur. Kendi `own-new-firmware.z1` dosyamızın 72 KB
text'i, içine gömülü OTA firmware örneğinden (`firmware_data.h`) kaynaklanır.

---

# 3. Symbol / Function Analizi

* Fonksiyon isimleri
* Global değişkenler
* Static değişkenler
* ISR (interrupt) fonksiyonları
* Contiki process entry’leri
* Radio driver fonksiyonları
* Timer callback’leri
* Networking callback’leri
* Sensor handler’ları
* Kullanılan kütüphaneler
* Kullanılmayan (dead) fonksiyonlar
* Function address mapping

Araçlar:

* `msp430-nm`
* `msp430-readelf`
* `msp430-objdump`
* `Ve üstteki araçların ARM versiyonları...`

## 🔬 Analiz Bulguları

Kullanılan komut: `nm -n <firmware>` — sembolleri adrese göre sıralı listeler.
Sembol türleri: `T/t`=kod (text), `D/d`=başlangıçlı veri, `B/b`=bss, `U`=tanımsız (dış).

| Firmware | Toplam sembol | Fonksiyon (T/t) | Tanımsız (U) | bss (B/b) | data (D/d) |
|----------|--------------|-----------------|--------------|-----------|------------|
| `nullnet-broadcast.z1` | 705 | 291 | 15 | 97 | 22 |
| `hello-world.z1` | 1011 | 502 | 13 | 171 | 40 |
| `own-udp-server.z1` | 1059 | 537 | 13 | 185 | 39 |
| `hardworker.z1` | 1039 | 519 | 13 | 172 | 48 |
| `base-demo.simplelink` | 1146 | 761 | 0 | 228 | 53 |
| `mtype5756516.cooja` | 1681 | 1109 | 22 | 415 | 112 |

Kendi `own-udp-server.z1` dosyamızdan OTA/CFS sembolleri (`nm` çıktısı):
```
00004c40 T cfs_open          0000508a T cfs_write
00004d10 T cfs_seek          0000725c T ota_crc32_buffer
00007318 T ota_metadata_mark_verified
000073a4 T ota_metadata_stage_verified_image
0000121e D udp_server_process
```

💡 **Yorum:** `nm` firmware'in **fonksiyon ve değişken haritasıdır**. `T` sembolleri
çalıştırılabilir fonksiyonlardır; sayıları kod karmaşıklığının kabaca ölçüsüdür —
`nullnet-broadcast.z1` 291 fonksiyonla en sade, `base-demo.simplelink` 761 fonksiyonla
en zengin uygulamadır. `U` (undefined) sembolleri normalde linkleme sırasında çözülür;
nihai çalıştırılabilir dosyada kalan birkaç `U` (MSP430'da 13–19) donanım register
adresleri gibi mutlak/zayıf sembollerdir. ARM dosyasında `U=0` olması linklemenin tam
kapalı olduğunu gösterir. Kendi OTA alıcımızda `cfs_*` (Coffee dosya sistemi) ve
`ota_metadata_*` sembollerinin **bulunması**, Part 1'de yazdığımız kalıcı depolama ve
metadata kodunun gerçekten firmware'e linklendiğini kanıtlar. `udp_server_process`'in
`D` (data) sembolü olması, Contiki process yapısının `static` bir struct olarak RAM'de
tutulduğunu gösterir. **Dead-code:** Contiki-NG `-ffunction-sections` + linker
`--gc-sections` kullanır; çağrılmayan fonksiyonlar zaten elenir, bu yüzden `nm`
çıktısındaki semboller pratikte "canlı" koddur.

---

# 4. String ve Metadata Analizi

* Debug mesajları
* printf logları
* IPv6 adresleri
* MAC adresleri
* Network node ID’leri
* Sensor isimleri
* Process isimleri
* Routing protokol isimleri
* TSCH/6LoWPAN/RPL stringleri
* Hidden diagnostic message’lar
* Hardcoded config değerleri
* Developer notları

Araçlar:

* `msp430-strings`
* `Ve üstteki aracın ARM versiyonu...`

## 🔬 Analiz Bulguları

Kullanılan komut: `strings <firmware>` — `.rodata` içindeki okunabilir metinleri çeker.

`nullnet-unicast.z1` içinden çıkan log şablonları:
```
Sending from node_id :%d, to linkaddr_node_addr :
Sending done from :%d
Received %u , node_id %d from
```

`base-demo.simplelink` içinden çıkan metadata:
```
Starting Contiki-NG-develop/v4.9-639-g6ac4608cd-dirty
CHIP_TYPE_CC1352P          batmon-sensor.c
CC1352P1_LAUNCHXL.c        button-sensor-arch.c
```

Kendi `own-udp-server.z1` dosyamızdan OTA mesajları:
```
=== OTA Alici Hazir ===
Slot B PENDING: sonraki acilista yeni firmware aktif olacak.
Blok %u/%u | offset=%lu | %u byte | cs=OK | toplam=%u
```

💡 **Yorum:** `strings` **en hızlı keşif aracıdır** — kodu sökmeden firmware'in ne
yaptığını ele verir. `printf`/`LOG_INFO` şablonlarındaki `%d %u` biçim belirteçleri,
çalışma anında hangi değişkenlerin basıldığını gösterir. `nullnet-unicast.z1`'in
"Sending from node_id" metni firmware'in bir **nokta-nokta haberleşme** uygulaması
olduğunu doğrular. `base-demo.simplelink`'teki `CHIP_TYPE_CC1352P`, `batmon-sensor.c`
(pil izleme), `button-sensor-arch.c` dizeleri donanımın **CC1352 LaunchPad** olduğunu
ve pil + buton sensörleri içerdiğini kesinleştirir. Her dosyadaki `Contiki-NG-...v4.x`
dizesi yapı sürümünü verir. Kendi firmware'imizde Part 1'de yazdığımız OTA protokol
mesajları (`Slot B PENDING`, `Blok %u/%u`) doğrudan görünür — bu, **ham binary yerine
ELF kullanmanın** ve `.rodata` bölümünün gücüdür. **Güvenlik notu:** hiçbir dosyada
parola/anahtar gibi hardcoded gizli bilgi görülmedi (bkz. Bölüm 21).

---

# 5. Assembly / Instruction Analizi

* Instruction sequence analizi
* Function prologue/epilogue
* Register kullanımı
* Stack frame yapısı
* ISR akışı
* Loop yapıları
* Branch analizi
* Jump table analizi
* Function call graph
* Inline function tespiti
* Compiler optimization davranışı
* Delay loop analizi
* Busy-wait yapıları
* Context switching
* Protothread expansion
* Scheduler davranışı

Araçlar:

* `msp430-objdump`
* `msp430-as`
* `Ve üstteki araçların ARM versiyonları...`

## 🔬 Analiz Bulguları

Kullanılan komut: `objdump -d <firmware>` — makine kodunu assembly'ye geri çevirir.

`own-udp-server.z1` — `main` fonksiyonu (MSP430):
```asm
0000313e <main>:
    313e:  b0 13 ca 75   calla  #0x075ca
    3142:  b0 13 1c 56   calla  #0x0561c
    314e:  0e 43         clr    r14
    3150:  3f 40 4e 11   mov    #4430, r15
```

`base-demo.simplelink` — `main` fonksiyonu (ARM Thumb-2):
```asm
00000a24 <main>:
     a24:  e92d 41f0   stmdb  sp!, {r4,r5,r6,r7,r8,lr}
     a28:  f001 fbce   bl     21c8 <platform_init_stage_one>
     a2c:  f7ff ff76   bl     91c  <clock_init>
     a34:  f001 fd10   bl     2458 <process_init>
```

💡 **Yorum:** `objdump -d` iki mimarinin **komut seti farkını** açıkça gösterir.
MSP430 tarafında **`calla`** (call absolute, 20-bit MSP430X adresleme) kullanılır;
fonksiyon çağrıları doğrudan mutlak adrese atlar. ARM tarafında fonksiyon **prologue**'u
klasik `stmdb sp!, {r4-r8, lr}` — yani kullanılacak register'lar ve dönüş adresi (`lr`)
tek komutla stack'e itilir; çağrılar `bl` (branch-link) ile yapılır. Bu, ARM'ın
**stack-frame** disiplininin MSP430'a göre daha düzenli olduğunu gösterir. ARM `main`'i
`platform_init_stage_one → clock_init → rtimer_arch_init → process_init` sırasıyla
çağırır; bu, **Contiki-NG açılış zincirinin** assembly seviyesinde okunabildiğini
kanıtlar. **Protothread genişlemesi:** Contiki `PROCESS_THREAD` makroları derlenince
bir `switch` deyimine dönüşür; `PROCESS_WAIT` noktaları `case` etiketleri olur — bu
yüzden process fonksiyonlarının disassembly'sinde dağınık `case` atlamaları görülür.
Bu, Contiki'nin **yığınsız (stackless) kooperatif zamanlayıcı** davranışının makine
kodundaki izidir.

---

# 6. Source-Level Mapping Analizi

(Debug build varsa)

* Address → source line eşleme
* Function → source file eşleme
* ISR → source mapping
* Crash address çözümleme
* Optimization sonrası source mapping
* Inline edilmiş kodların tespiti

Araçlar:

* `msp430-addr2line`
* `msp430-objdump -S`
* `Ve üstteki araçların ARM versiyonları...`

## 🔬 Analiz Bulguları

Kullanılan komut: `addr2line -f -e <firmware> <adres>` — bir bellek adresini
fonksiyon/satıra çevirir.

`own-udp-server.z1` üzerinde test:
```
$ msp430-addr2line -f -e own-udp-server.z1 0x313e 0x725c 0x4c40
main
??:0
ota_crc32_buffer
??:0
cfs_open
??:0
```

Tüm 16 firmware'de `.debug_*` bölüm sayısı: **8 adet** (`.debug_info`, `.debug_line`,
`.debug_abbrev`, `.debug_frame`, `.debug_str`, `.debug_loc`, `.debug_ranges`,
`.debug_aranges`).

💡 **Yorum:** `addr2line`, bir **çökme adresini** (crash address) okunabilir kod
konumuna çevirmek için kullanılır — gömülü sistem hata ayıklamasının temel aracıdır.
Testte adres → **fonksiyon adı** çevirisi başarılı oldu (`0x313e → main`,
`0x725c → ota_crc32_buffer`); bu, `.symtab` ve `.debug_info` bölümlerinin sağlam
olduğunu gösterir. Ancak **satır numarası** `??:0` döndü: bunun nedeni `.debug_line`
bölümünün, derleme anındaki **kaynak dosya yollarına** referans vermesi; o kaynak ağacı
analiz makinesinde bulunmadığı için satır eşlemesi tamamlanamadı. Yani fonksiyon
seviyesinde eşleme her zaman çalışır, satır seviyesi için **orijinal kaynak kodun
varlığı** gerekir. `objdump -S` ise assembly'yi kaynak satırlarla **iç içe** gösterir;
yine kaynak ağacı gerektirir. Tüm firmware'lerde 8 `.debug_*` bölümünün bulunması,
hepsinin **debug bilgisiyle** derlendiğini doğrular — bu da neden `.z1` dosyalarının
salt makine kodundan çok daha büyük olduğunu açıklar.

---

# 7. ELF Yapısı Analizi

* ELF header
* Section header
* Program header
* Symbol table
* Relocation entries
* Debug sections
* DWARF info
* Linker-generated metadata
* Startup section
* Vector table
* Initialization routines

Araçlar:

* `msp430-readelf`
* `msp430-elfedit`
* `Ve üstteki araçların ARM versiyonları...`

## 🔬 Analiz Bulguları

Kullanılan komut: `readelf -S` (bölümler) ve `readelf -l` (segmentler).

`own-new-firmware.z1` (Z1) bölümleri:
```
[ 1] .far.text  PROGBITS  00010000  ...  AX   <- uzak flash kodu
[ 2] .text      PROGBITS  00003100  ...  AX   <- ana kod
[ 3] .rodata    PROGBITS  0000c870  ...  A    <- salt-okunur sabitler
[ 4] .data      PROGBITS  00001100  ...  WA   <- başlangıçlı RAM verisi
[ 5] .bss       NOBITS    00001250  ...  WA   <- sıfır başlangıçlı RAM
[ 6] .noinit    NOBITS    00002898  ...  WA   <- reset'te korunan RAM
[ 7] .vectors   PROGBITS  0000ffc0  ...  AX   <- kesme vektör tablosu
```

`base-demo.simplelink` (ARM CC1352R) bölümleri — farklı bellek haritası:
```
[ 1] .resetVecs  PROGBITS  00000000  ...  A    <- ARM reset vektör tablosu
[10] .text       PROGBITS  00000040  ...  AX   <- kod (Flash)
[11] .rodata     PROGBITS  00010d14  ...  A
[12] .data       PROGBITS  20001b20  ...  WA   <- SRAM (0x2000_0000 bölgesi!)
[15] .ccfg       PROGBITS  00057fa8  ...  A    <- Customer Config alanı
[16] .bss        NOBITS    200020d8  ...  WA   <- SRAM
[17] .heap       NOBITS    20005200  ...  WA   <- heap (256 byte)
```

💡 **Yorum:** `readelf -S` firmware'in **iç organ haritasını** verir. MSP430'da kod
(`.text`), sabitler (`.rodata`) ve değişkenler (`.data`/`.bss`) hepsi **tek 16-bit
adres uzayında** iç içedir; `.vectors` her zaman uzayın tepesindedir (`0xFFC0`). Bazı
Z1 dosyalarında **`.far.text`** (`0x10000`) görülür — 64 KB'ı aşan kodu MSP430X'in
genişletilmiş flash'ına taşır. ARM/CC1352R **tamamen farklı bir mimari** sergiler:
Flash bölgesi `0x0000_0000`'dan, SRAM bölgesi `0x2000_0000`'dan başlar — kod ve veri
**ayrı fiziksel adres bloklarındadır** (Harvard benzeri). ARM dosyasındaki
**`.ccfg`** (Customer Configuration) bölümü kritiktir: CC1352R'ın ROM bootloader'ı
açılışta bu alanı okuyarak boot davranışını, debug kilidini ve flash koruma ayarlarını
belirler. **Segment (`readelf -l`)** ile **section** farkı: section'lar linker/derleyici
için ayrıntıdır; segment'ler (LOAD tipi) **donanıma fiilen yüklenecek** bloklardır —
firmware'i flash'a yazan araç segment'leri kullanır.

---

# 8. Interrupt ve Donanım Analizi

* Interrupt vector table
* GPIO access pattern
* Timer interrupt kullanımı
* UART ISR
* Radio interrupt handler
* ADC access
* Sensor polling
* Low-power mode geçişleri
* Clock configuration
* MSP430 register erişimleri

Araçlar:

* `msp430-objdump`
* `msp430-readelf`
* `Ve üstteki araçların ARM versiyonları...`

## 🔬 Analiz Bulguları

Kullanılan komut: `objdump -d -j .vectors <firmware>` — kesme vektör tablosunu döker.

`own-new-firmware.z1` (Z1 — `__ivtbl_32`, 64 byte):
```
0000ffc0 <__ivtbl_32>:
 ffc0: 76 33 76 33 ...        <- 32 adet 2-byte vektör
 fff0: ... 76 33 76 33 00 31  <- son 2 byte = RESET vektörü = 0x3100
```

`hello-world.sky` (Sky — `__ivtbl_16`, 32 byte):
```
0000ffe0 <__ivtbl_16>:
 ffe0: 7c 42 14 43 ...
 fff0: ... 7c 42 7c 42 00 40  <- son 2 byte = RESET = 0x4000
```

| Platform | Vektör tablosu | Adres | Boyut | Vektör sayısı |
|----------|---------------|-------|-------|---------------|
| Z1 (MSP430F2617) | `__ivtbl_32` | `0xFFC0` | 64 byte | 32 |
| Sky (MSP430F1611) | `__ivtbl_16` | `0xFFE0` | 32 byte | 16 |
| CC1352R (ARM) | `.resetVecs` | `0x00000000` | 64 byte | 16+ |

💡 **Yorum:** Kesme vektör tablosu, **donanım olayları ile yazılım arasındaki
köprüdür**: bir kesme (timer taşması, radyo paketi, GPIO) oluştuğunda CPU, ilgili
vektördeki adrese atlar. Z1 ile Sky farkı çarpıcı: **Z1's MSP430F2617** 32 kesme
kaynağına sahip (`__ivtbl_32`, 64 byte, `0xFFC0`'da); **Sky'ın MSP430F1611** ise yalnız
16 kaynak (`__ivtbl_16`, 32 byte, `0xFFE0`'da). Bu, aynı `.sky`/`.z1` uygulamasının
neden farklı entry point ve bellek haritasına sahip olduğunu açıklar — donanım farkı.
Her iki MSP430'da da tablonun **son 2 byte'ı RESET vektörüdür** ve entry point'i
gösterir (`0x3100` / `0x4000`); CPU'ya güç gelince ilk buraya bakar. ARM/CC1352R'da
tablo **adres uzayının başındadır** (`0x0`): ilk kelime stack pointer başlangıcı, ikinci
kelime reset handler adresidir — ARM Cortex-M standardı. GPIO/timer erişimleri ise
disassembly'de doğrudan donanım register adreslerine (`mov ... &0x0029` gibi MSP430
port register'ları) yazma olarak görülür.

---

# 9. Networking Analizi

* Unicast kullanım tespiti
* Broadcast kullanım tespiti
* Multicast tespiti
* IPv6 stack kullanımı
* RPL routing analizi
* TSCH scheduler çağrıları
* MAC layer interaction
* Packet buffer kullanımı
* Neighbor table erişimi
* Radio transmission akışı
* Retransmission logic
* ACK mekanizmaları
* CSMA/TSCH farkları
* Contiki network API kullanımı

Araçlar:

* `msp430-nm`
* `msp430-objdump`
* `msp430-strings`
* `Ve üstteki araçların ARM versiyonları...`

## 🔬 Analiz Bulguları

Kullanılan komut: `nm <firmware> | grep -c <protokol>` — ağ yığını sembollerini sayar.

| Firmware | `rpl_*` | `tsch_*` | `nullnet*` | `udp/uip` | `csma*` |
|----------|---------|----------|------------|-----------|---------|
| `own-udp-server.z1` | 70 | 0 | 0 | 106 | 3 |
| `hello-world.z1` | 70 | 0 | 0 | 94 | 5 |
| `hardworker.z1` | 77 | 0 | 0 | 101 | 5 |
| `nullnet-broadcast.z1` | 0 | 0 | 6 | 1 | 5 |
| `nullnet-unicast.z1` | 0 | 0 | 6 | 1 | 5 |
| `base-demo.simplelink` | 70 | 0 | 0 | 92 | 5 |

💡 **Yorum:** Sembol sayımı firmware'in **ağ mimarisini** ele verir. İki net aile
görülür: **(1) IPv6/RPL ailesi** — `own-udp-server.z1`, `hello-world.z1`, `hardworker.z1`
gibi dosyalar ~70 `rpl_*` ve ~100 `udp/uip` sembolü içerir; bunlar tam **6LoWPAN +
RPL yönlendirme + UDP** yığınını kullanır (bizim Part 1 OTA sistemimiz de bu ailededir).
**(2) NullNet ailesi** — `nullnet-broadcast/unicast` dosyalarında `rpl=0`, `udp=1` ama
`nullnet=6`; bunlar IPv6 yığınını **tamamen atlayıp** doğrudan MAC üzerinde ham paket
gönderir. NullNet, IP yükü olmadan minimum ağ katmanıdır — bu yüzden bu dosyalar çok
daha küçüktür (bkz. Bölüm 2: `nullnet-broadcast.z1` sadece 18 KB). `unicast` vs
`broadcast` farkı uygulama mantığındadır: biri tek hedefe, diğeri tüm komşulara gönderir.
**TSCH sembolü hiçbir dosyada yok** — yani tümü `csma` MAC katmanı kullanır (bkz.
Bölüm 10). Bizim OTA alıcımızdaki 106 `udp/uip` sembolü, stop-and-wait ACK protokolünün
UDP üstüne kurulduğunu doğrular.

---

# 10. Wireless / TSCH Analizi

* TSCH slot operation
* Channel hopping logic
* ASN handling
* Radio timing loops
* Synchronization routines
* Schedule management
* Packet timing
* MAC timing critical path
* Drift compensation
* Low-power radio behavior

Araçlar:

* `msp430-objdump`
* `msp430-nm`
* `Ve üstteki araçların ARM versiyonları...`

## 🔬 Analiz Bulguları

Kullanılan komut: `nm <firmware> | grep tsch` — TSCH zamanlayıcı sembollerini arar.

```
$ for fw in firmware-samples/*; do nm $fw | grep -c tsch_; done
# Sonuç: 16 firmware'in TAMAMINDA tsch_ sembol sayısı = 0
```

💡 **Yorum:** Analiz edilen **16 firmware'in hiçbirinde TSCH (Time-Slotted Channel
Hopping) sembolü bulunmadı**. Bu, eksik bir bulgu değil — anlamlı bir **tespittir**:
tüm firmware'ler MAC katmanı olarak **CSMA** (Carrier Sense Multiple Access)
kullanmaktadır (bkz. Bölüm 9'daki `csma` sembolleri). İki MAC'in farkı şudur: **CSMA**
asenkrondur — düğüm göndereceği zaman kanalı dinler, boşsa gönderir; basittir ama
radyoyu sürekli açık tutabilir. **TSCH** ise zaman dilimli + kanal atlamalıdır —
düğümler ortak bir zaman çizelgesinde (ASN: Absolute Slot Number) senkronize olur, her
slotta belirli bir kanala atlar; bu, hem **enerji verimliliği** (radyo yalnız kendi
slotunda açık) hem de **parazit dayanıklılığı** sağlar ama saat senkronizasyonu (drift
compensation) gerektirir. Bu repodaki örnekler eğitim/demo amaçlı olduğundan basitlik
için CSMA seçilmiştir. TSCH analizi yapılacak olsaydı `tsch_slot_operation`,
`tsch_schedule_*`, `tsch_adaptive_timesync_*` sembolleri ve radyo zamanlama döngüleri
disassembly'de incelenirdi.

---

# 11. Sensor ve Peripheral Analizi

* Button handler
* LED driver
* UART usage
* SPI access
* I2C access
* ADC routines
* Sensor polling interval
* Interrupt-driven sensor logic
* GPIO toggle behavior
* Peripheral initialization sequence

Araçlar:

* `msp430-objdump`
* `msp430-nm`
* `Ve üstteki araçların ARM versiyonları...`

## 🔬 Analiz Bulguları

Kullanılan komut: `nm <firmware> | grep -iE 'led|button|uart|spi|sensor'`.

`hardworker.z1` çevre birimi sembolleri:
```
U button_hal_button_count    b led_timer
D led_process                b udp_timer
D sensor_process             b loop_timer
D accmeter_process           D dummy_printer_process
```

`base-demo.simplelink` (CC1352R) — `strings` çıktısından:
```
batmon-sensor.c        button-sensor-arch.c
get_sync_sensor_readings
```

💡 **Yorum:** Çevre birimi (peripheral) sembolleri firmware'in **donanımla nasıl
etkileştiğini** gösterir. `hardworker.z1` zengin bir çevre birimi profili sergiler:
`led_process` + `led_timer` (zamanlayıcıyla LED yakıp söndürme), `accmeter_process`
(ivmeölçer — Z1 mote'unun üzerindeki ADXL345 sensörü), `button_hal_*` (buton kesmesi).
`button_hal_button_count`'ın **`U` (tanımsız)** olması, buton HAL'inin platform
katmanında tanımlı olduğunu ve uygulama tarafından dışarıdan referans alındığını
gösterir. `base-demo.simplelink` ise CC1352R LaunchPad'in **batmon-sensor** (dahili pil
voltajı/sıcaklık izleme) ve **button-sensor** sürücülerini içerir; `get_sync_sensor_readings`
fonksiyonu senkron sensör okuması yapar. **GPIO toggle** davranışı disassembly'de port
register'larına XOR yazma (`xor.b #bit, &PxOUT`) olarak görülür — LED yakıp söndürmenin
klasik kalıbı. Çevre birimi başlatma sırası `platform_init` zincirinde (bkz. Bölüm 5)
clock → GPIO → SPI/radyo → sensör şeklinde ilerler.

---

# 12. Algoritma Koşma / DSP / Matematiksel Analiz

* Floating-point kullanımı
* Fixed-point kullanımı
* Trigonometric computation
* Multiply/divide routines
* Software floating-point emulation
* DSP benzeri loop’lar
* Matrix operation izleri
* Signal processing pattern’leri
* Computational hotspot’lar
* Numerical optimization

Araçlar:

* `msp430-objdump`
* `msp430-gprof`
* `msp430-nm`
* `Ve üstteki araçların ARM versiyonları...`

## 🔬 Analiz Bulguları

Kullanılan komut: `nm <firmware> | grep -iE 'crc|checksum|mul|div|float'`.

Kendi `own-udp-server.z1` dosyamızdaki algoritmik blok:
```
0000725c T ota_crc32_buffer    <- CRC32 bütünlük hesabı (polinom 0xEDB88320)
```
ARM ELF başlığı (Bölüm 1): `soft-float ABI` — donanım FPU'su kullanılmıyor.

💡 **Yorum:** Bu firmware ailesi **DSP/ağır matematik uygulaması değildir** — gömülü
ağ düğümleri olduklarından hesaplama yükü düşüktür. Tespit edilen tek anlamlı
algoritmik blok, kendi OTA alıcımızdaki **`ota_crc32_buffer`** — Part 1'de yazdığımız,
firmware bütünlüğünü doğrulayan CRC32 hesabıdır (her byte için 8 bit-kaydırma + XOR).
**Kayan nokta:** MSP430'da donanım FPU'su yoktur; eğer `float` kullanılsaydı derleyici
`__mspabi_mpyf` gibi **yazılım emülasyon** rutinleri eklerdi. ARM/CC1352R'da Cortex-M4
**F** çekirdeği donanım FPU'suna sahip olmasına rağmen, `base-demo.simplelink`'in ELF
bayrağı **`soft-float ABI`** gösterir — yani derleyici yine de yazılım kayan-nokta çağrı
uzlaşımı seçmiş (gömülü Contiki yapılarında yaygın bir tercih: kod taşınabilirliği ve
kesme bağlamında FPU register'larını kaydetme maliyetinden kaçınma). **Çarpma/bölme:**
MSP430'un donanım çarpıcısı (hardware multiplier) varsa derleyici onu kullanır; yoksa
`__mspabi_mpyi` rutini çağrılır — bunlar disassembly'de görülebilir. DSP benzeri sıkı
döngüler veya matris işlemi izine rastlanmadı.

---

# 13. Güç ve Performans Analizi

* Low-power mode geçişleri
* CPU-intensive function’lar
* Busy-wait detection
* Sleep/wakeup flow
* Timer usage intensity
* Radio duty cycle tahmini
* ISR yoğunluğu
* Function execution cost
* Flash/RAM efficiency
* Energy-heavy computation bölgeleri

Araçlar:

* `msp430-gprof`
* `msp430-objdump`
* `msp430-size`
* `Ve üstteki araçların ARM versiyonları...`

## 🔬 Analiz Bulguları

`msp430-gprof` **çalışma anı (runtime)** profili gerektirir; statik bir `.z1` dosyasından
profil üretilemez. Bunun yerine **statik göstergeler** kullanıldı:

| Gösterge | Kaynak | Yorumlanan anlam |
|----------|--------|------------------|
| `.text` boyutu | `size` | Flash'tan komut çekme maliyeti |
| `bss`/`data` | `size` | RAM baskısı |
| `lpm`/`LPM` sembolleri | `nm` | Düşük güç moduna geçiş noktaları |
| Timer/ctimer sembolleri | `nm` | Periyodik uyanma yoğunluğu |

💡 **Yorum:** Gerçek güç profili ölçüm donanımı veya enstrümante edilmiş yapı
gerektirir; örnek firmware'ler bu şekilde derlenmediğinden `gprof` **uygulanamadı** —
bu dürüstçe belirtilir. Ancak statik analiz yine de güçlü ipuçları verir: Contiki-NG'nin
olay-güdümlü (event-driven) zamanlayıcısı, yapacak iş kalmadığında CPU'yu **LPM (Low
Power Mode)**'a sokar; `nm` çıktısındaki `lpm`/uyku sembolleri ve `etimer`/`ctimer`
kullanımı, düğümün ne sıklıkta uyanıp uyuduğunu gösterir. **Busy-wait** (meşgul bekleme)
enerji düşmanıdır — disassembly'de koşulu sürekli yoklayan sıkı döngüler olarak görülür;
örneklerde radyo başlatma dışında yaygın busy-wait görülmedi. **Flash/RAM verimliliği:**
`nullnet-broadcast.z1` (18 KB flash) en verimli, `hardworker.z1` (74 KB) en yoğun
profildir — `hardworker` adı zaten çok-process'li yoğun bir iş yükünü ima eder (bkz.
Bölüm 23). Radyo **duty cycle**'ı CSMA MAC ile yönetilir; radyonun açık kalma oranı
firmware'in en büyük enerji kalemidir.

---

# 14. Coverage ve Profiling Analizi

* Function call frequency
* Execution hotspot
* Unused branch’ler
* Rarely executed path’ler
* Test coverage
* Critical execution path
* Runtime bottleneck’ler

Araçlar:

* `msp430-gcov`
* `msp430-gprof`
* `Ve üstteki araçların ARM versiyonları...`

## 🔬 Analiz Bulguları

`gcov` ve `gprof` **enstrümante edilmiş yapı + çalışma anı verisi** gerektirir:
- `gcov`: kaynak `-fprofile-arcs -ftest-coverage` ile derlenmeli, çalıştırılmalı,
  `.gcda`/`.gcno` dosyaları üretilmeli.
- `gprof`: kaynak `-pg` ile derlenmeli, çalışınca `gmon.out` üretmeli.

Verilen örnek `.z1`/`.sky`/`.simplelink` dosyaları bu bayraklarla derlenmediğinden
(ve gömülü hedefte `gmon.out` yazacak dosya sistemi olmadığından) **bu bölümün
komut tabanlı çıktısı üretilemez.**

💡 **Yorum:** Coverage/profiling, **dinamik analiz** kategorisindedir — statik bir
firmware imajından elde edilemez; bu yüzden uygulanamaması beklenen bir durumdur ve
dürüstçe belirtilir. Yine de **yöntem** açıklanabilir: `gcov` kodun hangi satır/dalının
çalıştırıldığını sayar → **test kapsamı** ve hiç çalışmayan **ölü dallar** bulunur.
`gprof` ise fonksiyon çağrı sıklığını ve süresini ölçer → **execution hotspot** ve
**darboğazlar** tespit edilir. Gömülü sistemlerde bunlar genellikle Cooja simülatöründe
ya da seri port üzerinden çıktı toplayarak yapılır. **Statik alternatif:** çağrı
grafiği `objdump -d` ile `calla`/`bl` komutları taranarak çıkarılabilir; bizim Part 1
simülasyonumuzda Cooja log'ları (her bloğun gönderim/ACK satırı) fiilen bir **runtime
trace** işlevi görmüştür — yani protokolün kritik yolu (chunk gönder → ACK bekle)
gözlemlenmiştir.

---

# 15. Reverse Engineering Analizi

* Firmware behavior recovery
* Unknown firmware classification
* Feature inference
* Protocol inference
* ISR purpose discovery
* Hardware interaction recovery
* State machine extraction
* Scheduler reconstruction
* Event-flow reconstruction
* Network role inference

Araçlar:

* `msp430-objdump`
* `msp430-nm`
* `msp430-readelf`
* `msp430-strings`
* `Ve üstteki araçların ARM versiyonları...`

## 🔬 Analiz Bulguları

`nullnet-broadcast.z1` vs `nullnet-unicast.z1` davranış çıkarımı (sembol + string):
```
nullnet-broadcast.z1: nullnet=6, rpl=0, csma=5, 18 KB  -> ham broadcast
nullnet-unicast.z1  : nullnet=6, rpl=0, csma=5, 30 KB
  String: "Sending from node_id :%d, to linkaddr_node_addr :"
```

💡 **Yorum:** Reverse engineering, **hiç dokümantasyonu olmayan bir firmware'in ne
yaptığını** araç zinciriyle çıkarmaktır. İzlenen yöntem dört adımlıdır: **(1)** `readelf -h`
→ platform/mimari (bkz. Bölüm 1); **(2)** `strings` → uygulama amacı; **(3)** `nm` →
hangi alt sistemler linklenmiş; **(4)** `objdump -d` → kritik mantık. Bu yöntemle
`nullnet-unicast.z1`'in rolü çıkarıldı: `rpl=0` olduğu için **yönlendirme yok**,
`nullnet` sembolleri var → ham MAC haberleşmesi, string'i ise **belirli bir hedefe**
(`linkaddr_node_addr`) gönderim yaptığını söylüyor → sonuç: bu bir **nokta-nokta
unicast** demo'sudur. `broadcast` sürümü ise tüm komşulara yayın yapar ve daha küçüktür
çünkü hedef seçme/komşu tablosu mantığı azdır. **Ağ rolü çıkarımı** kendi
firmware'lerimizde de işler: `own-udp-server.z1`'de `NETSTACK_ROUTING.root_start` ve
`cfs_*` sembollerinin bulunması onun **DAG kökü + OTA alıcısı** olduğunu; `own-udp-client.z1`'de
`firmware_payload` sembolünün bulunması onun **OTA göndericisi** olduğunu kanıtlar.
Detaylı bir uygulama örneği için bkz. Bölüm 23.

---

# 16. Compiler ve Optimization Analizi

* `-O0/-O2/-Os` farkları
* Inlining behavior
* Dead code elimination
* Constant folding
* Loop optimization
* Register allocation
* Tail-call optimization
* Branch optimization
* Macro expansion
* Preprocessor etkileri

Araçlar:

* `msp430-gcc`
* `msp430-cpp`
* `msp430-objdump`
* `Ve üstteki araçların ARM versiyonları...`

## 🔬 Analiz Bulguları

Contiki-NG varsayılan olarak **`-Os`** (boyut için optimize) kullanır. Kendi Part 1
projemizde de `Makefile`'a `CFLAGS += -Os` eklenmiştir — bunun somut bir nedeni vardır:

```
Sorun : msp430-gcc 4.7.4 ile -O0'da "undefined reference to mac_call_sent_callback"
Neden : Eski derleyici, -O0'da `static inline` fonksiyonların yerel kopyasını üretmiyor
Çözüm : -Os ile optimizer inline'ı zorlar -> sembol çözülür
```

💡 **Yorum:** Optimizasyon seviyesi firmware'in hem **boyutunu** hem **davranışını**
etkiler. **`-O0`** (optimizasyon yok): kod birebir kaynağa benzer, hata ayıklaması
kolaydır ama büyüktür ve yavaştır. **`-Os`**: kod boyutunu küçültür — gömülü sistemlerin
sınırlı flash'ı için idealdir; bu yüzden Contiki-NG'nin tercihidir. **`-O2`**: hız
odaklıdır, agresif inlining yapar. Bu projede `-O0 → -Os` geçişi sadece bir tercih
değil **zorunluluktu**: eski msp430-gcc 4.7.4, `-O0`'da `static inline` fonksiyonlar
için yerel kopya üretmediğinden linker hatası veriyordu; `-Os` optimizer'ı inline'ı
gerçekleştirdiği için sorun çözüldü. Bu, **derleyici optimizasyonunun derleme
başarısını dahi etkileyebileceğinin** somut kanıtıdır. **Diğer izler:** `-Os` ile
**dead-code elimination** (kullanılmayan fonksiyonların atılması) ve **inlining** (küçük
fonksiyonların çağıran içine gömülmesi) yapılır — bu yüzden disassembly'de bazı kaynak
fonksiyonları ayrı görünmez. Contiki ayrıca `-ffunction-sections` + `--gc-sections`
ile bölüm bazlı çöp toplama yapar (bkz. Bölüm 17).

---

# 17. Linker ve Build Sistemi Analizi

* Section placement
* Link order
* Static library linkage
* Startup code
* Linker script behavior
* Vector placement
* Symbol resolution
* Relocation behavior

Araçlar:

* `msp430-ld`
* `msp430-ar`
* `msp430-ranlib`
* `msp430-readelf`
* `Ve üstteki araçların ARM versiyonları...`

## 🔬 Analiz Bulguları

Bölümlerin sabit adreslere yerleşimi (linker script çıktısı, `readelf -S`):

| Bölüm | Z1 yerleşimi | Sky yerleşimi | ARM yerleşimi | Yerleştiren |
|-------|--------------|---------------|---------------|-------------|
| `.text` | `0x3100` | `0x4000` | `0x40` | Linker script |
| `.data` | `0x1100` (RAM) | `0x1100` (RAM) | `0x20001b20` (SRAM) | Linker script |
| `.vectors` | `0xFFC0` | `0xFFE0` | `0x0` | Linker script (sabit!) |

💡 **Yorum:** **Linker (`ld`)**, derleyicinin ürettiği nesne dosyalarını birleştirip
her bölümü **donanımın beklediği fiziksel adrese** yerleştirir. Bu yerleşim rastgele
değildir — platforma özel bir **linker script** tarafından dikte edilir. En kritik
örnek **`.vectors`**'tür: MSP430 donanımı reset vektörünü **her zaman** flash'ın tepesinde
(`0xFFFE`) arar; linker script bu yüzden `.vectors`'ı `0xFFC0`/`0xFFE0`'a **zorla**
yerleştirir — bir byte şaşsa cihaz boot etmez. Aynı şekilde `.text` Z1'de `0x3100`,
Sky'da `0x4000`'dedir çünkü her MSP430 türevinin flash başlangıcı farklıdır. ARM'da
`.text` `0x40`'tan başlar (ilk 64 byte `.resetVecs`'e ayrılmıştır). **Startup code:**
`.text`'in en başındaki `_reset_vector__` rutini, `.data`'yı flash'tan RAM'e kopyalar,
`.bss`'i sıfırlar, sonra `main`'i çağırır — bu, linker-üretimi (linker-generated)
başlangıç kodudur. **Static library linkage:** Contiki-NG'nin yeni build sistemi tek bir
`.a` arşivi yerine nesne dosyalarını doğrudan linkler (bkz. Bölüm 19); `--gc-sections`
sayesinde kullanılmayan bölümler atılır. **Symbol resolution:** linker tüm `U`
sembollerini bu aşamada çözer; çözülemeyen sembol "undefined reference" hatası verir —
Part 1'de yaşadığımız `mac_call_sent_callback` hatası tam olarak buydu.

---

# 18. Binary Transformation Analizi

* ELF → HEX conversion
* ELF → binary conversion
* Section extraction
* Symbol stripping
* Debug removal
* Firmware minimization
* Binary patch preparation

Araçlar:

* `msp430-objcopy`
* `msp430-strip`
* `Ve üstteki araçların ARM versiyonları...`

## 🔬 Analiz Bulguları

`own-udp-server.z1` üzerinde canlı dönüşüm testi:
```
$ msp430-objcopy -O ihex   own-udp-server.z1  fw.hex   ->  144 592 byte
$ msp430-objcopy -O binary own-udp-server.z1  fw.bin   ->   52 992 byte
$ msp430-strip             own-udp-server.z1  -o fw-stripped.z1 -> 52 144 byte
  Orijinal ELF: 112 496 byte

HEX ilk satırı:  :103100005542200135D0085A82451E2A31400031EF
```

| Çıktı | Boyut | Format |
|-------|-------|--------|
| Orijinal `.z1` (ELF) | 112 496 B | ELF + debug + semboller |
| `strip`'lenmiş ELF | 52 144 B | ELF, debug yok |
| Ham binary (`.bin`) | 52 992 B | Sadece byte'lar |
| Intel HEX (`.hex`) | 144 592 B | Metin (adres + checksum) |

💡 **Yorum:** `objcopy` ve `strip`, bir firmware'i **bir formattan diğerine çevirir**.
Çarpıcı bulgu: `strip` ile ELF **112 KB → 52 KB**'a düştü — yani orijinal dosyanın
**yarısından fazlası debug bilgisi ve sembol tablosuydu** (`.debug_*`, `.symtab`,
`.strtab`). Bu, neden `.z1` dosyalarının çalışan koddan çok daha büyük olduğunu
kesinleştirir (bkz. Bölüm 1, 6). **Ham binary** (`.bin`) sadece flash'a yazılacak
byte'ları içerir (52 KB) — en küçüğü; ama içinde **adres bilgisi yoktur**, nereye
yükleneceğini bilmek imkânsızdır. **Intel HEX** (`.hex`) ise en büyüğüdür (144 KB)
çünkü **metin** formatıdır: her satır `:` + uzunluk + adres + veri + checksum içerir
(`:10 3100 00 ...EF`). HEX, programlayıcı araçların tercih ettiği formattır çünkü her
satırda **hedef adres** ve **bütünlük checksum'u** taşır. **OTA bağlamı:** Part 1'de
biz de aynı mantığı kullandık — firmware'i bloklara bölüp her bloğa offset + checksum
ekledik; `objcopy`'nin HEX üretmesiyle bizim chunk protokolümüz kavramsal olarak aynı
işi yapar. `strip` ise OTA öncesi firmware'i küçültmek (debug bilgisini atmak) için
kullanılır — daha az byte = daha hızlı kablosuz transfer.

---

# 19. Library ve Archive Analizi

* Static library içeriği
* Object file extraction
* Archive symbol table
* Linked module analizi

Araçlar:

* `msp430-ar`
* `msp430-gcc-ar`
* `msp430-ranlib`
* `Ve üstteki araçların ARM versiyonları...`

## 🔬 Analiz Bulguları

Contiki-NG'nin güncel build sistemi tek bir `.a` arşivi üretmek yerine nesne dosyalarını
(`build/z1/obj/*.o`) **doğrudan linkler**:
```
$ find build -name "*.a"
(sonuç yok - tek arşiv dosyası üretilmiyor)
$ ls build/z1/obj/
   ... .o nesne dosyaları doğrudan linkleniyor ...
```

💡 **Yorum:** Bir **statik kütüphane (`.a` arşivi)**, derlenmiş `.o` nesne dosyalarının
`ar` aracıyla paketlenmiş halidir — `msp430-ar t lib.a` içeriği listeler, `msp430-ar x`
çıkarır, `msp430-ranlib` sembol indeksini oluşturur. Ancak analiz edilen firmware'ler
**nihai linklenmiş çalıştırılabilir dosyalardır** — kütüphaneler zaten içlerinde
eritilmiştir; bu yüzden bir `.z1` dosyasına `ar` uygulanamaz. Ayrıca Contiki-NG'nin
yeni Make tabanlı build sistemi, eski sürümlerdeki tek `contiki-ng-z1.a` arşivini
**üretmez** — nesne dosyalarını (`build/z1/obj/*.o`) linker'a doğrudan verir ve
`--gc-sections` ile kullanılmayanları eler. Dolayısıyla bu bölüm örnek firmware'ler
için **doğrudan uygulanamaz**; yöntem yine de geçerlidir: eğer elimizde
`libcontiki.a` gibi bir arşiv olsaydı, `ar t` ile hangi modüllerin (rpl.o, csma.o,
cc2420.o...) bulunduğu listelenir, `nm` ile her modülün sağladığı semboller incelenirdi.
Linklenmiş modüllerin **izleri** yine de görülebilir: `nm` çıktısındaki `rpl_*`,
`csma_*`, `cc2420_*` sembol kümeleri, hangi kütüphane modüllerinin firmware'e dahil
edildiğini gösterir.

---

# 20. Contiki-NG Özel Analizler

* PROCESS_THREAD recovery
* Protothread expansion
* Event-driven scheduler analizi
* etimer/ctimer usage
* PROCESS_BEGIN/END expansion
* PROCESS_YIELD flow
* NETSTACK interaction
* Packetbuf lifecycle
* uIP callback chain
* Rime stack usage

Araçlar:

* `msp430-cpp`
* `msp430-objdump`
* `msp430-nm`
* `Ve üstteki araçların ARM versiyonları...`

## 🔬 Analiz Bulguları

`hardworker.z1` içindeki Contiki process sembolleri (`nm`):
```
00001100 D accmeter_process     00001156 D sensor_process
0000110c D cc2420_process       00001162 D udp_process
00001130 D ctimer_process       0000116e D led_process
0000113c D etimer_process       000011fc D sensors_process
0000114a D dummy_printer_process 00001208 D stack_check_process
                                 00001214 D tcpip_process
```

💡 **Yorum:** Contiki-NG'nin kalbi **protothread (yığınsız iş parçacığı)** modelidir
ve analiz bunun izlerini net gösterir. Her `PROCESS(...)` makrosu, RAM'de bir **`struct
process`** oluşturur — bu yüzden `nm` çıktısında process'ler `D` (data) sembolü olarak
görünür ve hepsi `0x1100` civarında, yani RAM'in başında kümelenir. `hardworker.z1`'de
**11 ayrı process** bulunması, firmware'in oldukça çok-görevli olduğunu gösterir
(`accmeter`, `sensor`, `led`, `udp`, `tcpip`...). **PROCESS_THREAD makrosu** derlenince
bir `switch(process_pt->lc)` deyimine dönüşür; **PROCESS_BEGIN/END** switch'i açıp
kapatır; **PROCESS_WAIT_EVENT_UNTIL** ise bir `case` etiketi üretir — protothread bir
olay beklerken `return` eder, olay gelince `switch` ile **tam kaldığı `case`'e geri
döner**. Part 1'de bu mekanizmanın inceliğini bizzat yaşadık: erken `PROCESS_END()`
çağrısı switch'i erkenden kapattığı için "case label not within switch" hatası almıştık.
**etimer/ctimer:** `etimer_process` ve `ctimer_process` sembolleri, olay-güdümlü
zamanlayıcının çekirdek parçalarıdır — `etimer` process'lere olay yollar, `ctimer`
callback çağırır. **NETSTACK etkileşimi:** `tcpip_process` + `cc2420_process` zinciri,
gelen radyo paketinin sürücüden IP yığınına nasıl aktığını gösterir. **`stack_check_process`**
ise RAM yığın taşmasını izleyen bir güvenlik process'idir (bkz. Bölüm 21).

---

# 21. Güvenlik ve Robustness Analizi

* Hardcoded credential arama
* Debug backdoor izleri
* Buffer handling
* Unsafe memory access
* Stack-heavy routines
* Potential overflow bölgeleri
* Assert/debug remnants
* Information leakage string’leri

Araçlar:

* `msp430-strings`
* `msp430-objdump`
* `msp430-readelf`
* `Ve üstteki araçların ARM versiyonları...`

## 🔬 Analiz Bulguları

Kullanılan komut: `strings <firmware> | grep -iE 'password|key|secret|token|admin'`.
```
$ for fw in firmware-samples/*; do strings $fw | grep -iE 'password|secret|key=' ; done
(sonuç yok - hardcoded gizli bilgi bulunamadı)
```
Bulunan robustness sembolleri: `stack_check_process` (hardworker.z1), CRC32 + checksum
(own-udp-server.z1).

💡 **Yorum:** Güvenlik analizinin ilk adımı **hardcoded gizli bilgi** aramaktır —
parola, API anahtarı, debug arka kapısı string'leri. Taranan 16 firmware'in hiçbirinde
böyle bir sızıntı **bulunmadı**; bu beklenen bir sonuç çünkü hepsi eğitim/demo
firmware'idir. **Buffer handling:** gömülü C kodunun en büyük riski tampon taşmasıdır;
kendi Part 1 kodumuzda bunu bilinçli olarak ele aldık — OTA alıcı, gelen her paket için
`datalen < HEADER_LEN` ve `datalen != HEADER_LEN + payload_len` kontrolleri yapar,
yani **paket boyutu doğrulanmadan belleğe yazılmaz**. **Bütünlük:** OTA protokolümüz
hem blok başına XOR checksum hem tüm imaj için CRC32 kullanır — bozuk/eksik veri
tespiti sağlar. **`stack_check_process`** (hardworker.z1'de görülen), Contiki-NG'nin
RAM yığınına bir imza yazıp periyodik kontrol eden **yığın taşması dedektörüdür** —
8 KB RAM'li bir cihazda yığın/heap çakışması ciddi bir risktir. **Assert kalıntıları:**
`strings` çıktısında dosya adı + satır numarası içeren assert mesajları debug
build'lerde kalır; bunlar saldırgana kod yapısı hakkında bilgi sızdırabilir — üretim
firmware'inde `strip` ile temizlenmeleri önerilir (bkz. Bölüm 18). **Debug erişimi:**
ARM/CC1352R'da `.ccfg` bölümü JTAG/debug kilidini kontrol eder; üretimde debug
arayüzünün kapatılması güvenlik için kritiktir.

---

# 22. Karşılaştırmalı Firmware Analizi

İki firmware arasında:

* Code size farkı
* RAM farkı
* Function count farkı
* ISR yoğunluğu
* Networking complexity
* Radio stack farkı
* Symbol farkı
* Optimization farkı
* Assembly complexity farkı

## 🔬 Analiz Bulguları

**16 firmware ana karşılaştırma tablosu:**

| Firmware | Platform | Flash (B) | RAM (B) | Fonk. | Ağ yığını | Disasm satır |
|----------|----------|-----------|---------|-------|-----------|--------------|
| `nullnet-broadcast.z1` | Z1 | 18 032 | 2 406 | 291 | NullNet+CSMA | 6 585 |
| `nullnet-unicast.z1` | Z1 | 30 585 | 5 120 | 317 | NullNet+CSMA | — |
| `nullnet-unicast-u50.sky` | Sky | 18 103 | 3 124 | 262 | NullNet+CSMA | — |
| `nullnet-unicast.sky` | Sky | 33 597 | 7 512 | 300 | NullNet+CSMA | — |
| `hello-world.z1` | Z1 | 41 840 | 6 004 | 502 | RPL+UDP+CSMA | 15 463 |
| `hello-world.sky` | Sky | 42 561 | 7 038 | 474 | RPL+UDP+CSMA | — |
| `udp-client.z1` | Z1 | 42 878 | 6 224 | 510 | RPL+UDP+CSMA | — |
| `own-udp-client.z1` | Z1 | 49 935 | 6 312 | 512 | RPL+UDP+CSMA | — |
| `own-udp-server.z1` | Z1 | 51 388 | 6 432 | 537 | RPL+UDP+CFS | 18 503 |
| `own-new-firmware.z1` | Z1 | 72 051 | 6 042 | 530 | RPL+UDP | — |
| `hardworker.z1` | Z1 | 73 938 | 6 072 | 519 | RPL+UDP+sensör | — |
| `base-demo.simplelink` | CC1352R | 72 801 | 14 376 | 761 | RPL+UDP+sensör | 27 897 |
| `mtype5756516.cooja` | x86-64 | — | — | 1109 | RPL+UDP | — |

💡 **Yorum:** Karşılaştırmalı analiz, firmware'ler arası **mimari ve uygulama
farklarını** sayısallaştırır. **Ağ yığını en büyük belirleyicidir:** NullNet
firmware'leri (18–33 KB) IPv6/RPL yığınını atladıkları için RPL+UDP firmware'lerinin
(42–74 KB) yarısı kadardır — bir firmware'e RPL eklemek ~24 KB flash maliyetidir.
**Platform farkı:** aynı `hello-world` uygulaması Z1'de 41 840 B, Sky'da 42 561 B
flash kullanır — kod neredeyse aynı, fark donanım soyutlama katmanından gelir; ancak
Sky daha çok RAM (`bss`) harcar çünkü farklı sürücüler içerir. **ISR yoğunluğu:** Z1
32 kesme vektörü, Sky 16 kesme vektörü destekler (bkz. Bölüm 8). **En karmaşık
firmware** `base-demo.simplelink` (ARM): 761 fonksiyon, 27 897 satır disassembly —
çünkü ARM komut seti daha geniş ve CC1352R çok sayıda çevre birimi içerir.
**Optimizasyon:** hepsi `-Os` ile derlenmiş, dolayısıyla optimizasyon farkı yok; fark
tamamen **uygulama kapsamından** gelir. **Kendi firmware'lerimiz:** `own-udp-server.z1`
(537 fonk., CFS dahil) `own-udp-client.z1`'den (512 fonk.) biraz büyük — alıcı, Coffee
dosya sistemi + OTA metadata kodunu ek olarak taşıdığı için. `own-new-firmware.z1`'in
72 KB'lik boyutu ise içine gömülü OTA örnek payload'undan kaynaklanır — yani "taşınan
firmware" ile "taşıyan firmware" boyut olarak ayrışır.

---

# 23. Eğitimsel Reverse Engineering Görevleri

* Bir firmware’in ne yaptığını bulma
* hangi protokolü kullandığını çıkarma
* button/LED mapping bulma
* ISR’leri tanıma
* network role çıkarımı
* Kullandığı algoritmik blok tespiti
* energy-heavy bölgeleri bulma
* stripped firmware çözümleme

## 🔬 Analiz Bulguları — Vaka: `hardworker.z1` "Gizemli Firmware"

Hiçbir dokümantasyonu yokmuş gibi, sadece araç zinciriyle `hardworker.z1` çözümlendi:

**Adım 1 — Kimlik (`readelf -h`):** ELF32, MSP430, entry `0x3100` → bir **Z1 mote**
firmware'i. **`strings`** → `Contiki-NG v4.9-639` ile derlenmiş.

**Adım 2 — Ne yapıyor? (`nm` process'leri):**
```
led_process, accmeter_process, sensor_process, udp_process,
dummy_printer_process, sensors_process, stack_check_process, tcpip_process
```

**Adım 3 — İpucu string'ler:**
```
[LED] Toggled            LED Toggle P.ID:03
failed to create packet, seqno: %d
failed to create a new RPL DAG
```

**Adım 4 — Ağ rolü (`nm`):** `rpl=77`, `udp/uip=101`, `tsch=0` → **RPL + UDP**
üzerinden CSMA MAC ile haberleşiyor.

💡 **Yorum — Firmware davranış kurtarma:** Hiçbir kaynak koda bakmadan, yalnızca
`readelf` + `nm` + `strings` üçlüsüyle `hardworker.z1`'in **tam profili** çıkarıldı:
Bu, bir **Z1 mote** üzerinde koşan, **çok-process'li yoğun bir IoT düğüm** firmware'idir
("hardworker" = çok çalışan). **Davranışı:** (1) `led_process` LED'i periyodik yakıp
söndürür (`"[LED] Toggled"`, `P.ID:03` → process ID 3); (2) `accmeter_process` +
`sensor_process` Z1 üzerindeki **ivmeölçer ve sensörleri** okur; (3) `udp_process`
RPL ağı üzerinden **UDP paketleri** gönderir (`"failed to create packet, seqno"` →
sıra numaralı paket üretimi var); (4) `dummy_printer_process` test/debug çıktısı basar;
(5) `stack_check_process` RAM yığınını korur. **Ağ rolü:** `rpl=77` sembolü ile bir
**RPL ağ düğümü**dür ama `rpl_dag_root` çağrısı olup olmadığına bakılarak kök mü yaprak
mı olduğu ayrıca belirlenebilir. **ISR tanıma:** `cc2420_process` → CC2420 radyo
kesmesi, `etimer/ctimer_process` → zamanlayıcı kesmeleri. **Enerji:** 74 KB flash + 11
process ile bu, repodaki **en yoğun iş yüküne** sahip firmware'dir — adı bunu doğrular.
**Sonuç:** Bu vaka, araç zincirinin (toolchain) gücünü kanıtlar — kapalı bir binary,
doğru araçlarla **tamamen şeffaf** hale gelir. Aynı yöntem `strip`'lenmiş bir firmware'e
uygulansaydı sembol isimleri kaybolurdu; o durumda `strings` ve `objdump -d` ile davranış
çıkarımı daha zor ama yine mümkün olurdu.

---

## 📌 Sonuç

Bu çalışmada **4 farklı platformda** (MSP430-Z1, MSP430-Sky, ARM-CC1352R,
x86-cooja-native) derlenmiş **16 firmware**, MSP430 ve ARM araç zincirleri kullanılarak
**23 başlık altında** analiz edilmiştir. Her komut çıktısı, salt kopyalanmak yerine
firmware'in rolü ve mimari anlamı açısından **yorumlanmıştır**. Analizler, Part 1'de
geliştirdiğimiz OTA firmware güncelleme sisteminin (`own-*.z1`) yapısını da doğrulamış;
gömülü bir firmware'in ELF yapısı, bellek yerleşimi, kesme mekanizması ve ağ davranışının
araç zinciriyle nasıl tamamen çözümlenebileceğini göstermiştir.

*Ham analiz çıktıları `analysis-output/` klasöründe, analiz betiği `run-analysis.sh`
dosyasında, incelenen firmware'ler `firmware-samples/` klasöründedir.*
