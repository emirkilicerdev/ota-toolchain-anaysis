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
> hazırlanmıştır. Şablon repodan fork'lanmış, **23 analiz başlığının her birinin**
> altına gerçek firmware analiz sonuçları, **şablon maddelerini tek tek karşılayan
> "Madde madde bulgular" tablosu** ve bir **"💡 Yorum"** sentez paragrafı eklenmiştir.
>
> **Hocanın kuralı:** *"Yalnızca komut çıktısını kopyalamak yeterli değildir — araç
> zincirinin kullanım amacı ve çıktıların anlamı yorumlanmalıdır."* Bu kural her
> başlıkta uygulanmıştır.

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

Analizler `run-analysis.sh` betiği ile toplu üretilmiştir. Betik her dosyanın uzantısına
göre doğru araç zincirini seçer:

| Uzantı | Platform | Araç ön eki |
|--------|----------|-------------|
| `.z1` / `.sky` | MSP430 | `msp430-*` (Contiki-NG Docker imajında hazır) |
| `.simplelink` | ARM Cortex-M4F | `arm-none-eabi-*` (GNU Arm Embedded 9-2020-q2) |
| `.cooja` | x86-64 native | standart GNU binutils (`readelf`, `objdump`...) |

Ham çıktılar `analysis-output/` klasörüne dökülür (her firmware için 10 dosya).

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

**Kullanılan komut:** `readelf -h <firmware>` (ELF başlığı), `strings` (derleyici izi).

| Firmware | ELF Sınıfı | Mimari | Tür | Entry | Endian |
|----------|-----------|--------|-----|-------|--------|
| `*.z1` (8 dosya) | ELF32 | TI MSP430 | EXEC | `0x3100` | little |
| `*.sky` (6 dosya) | ELF32 | TI MSP430 | EXEC | `0x4000` | little |
| `base-demo.simplelink` | ELF32 | ARM | EXEC | `0x6751` | little |
| `mtype5756516.cooja` | ELF64 | x86-64 | DYN | `0x14b00` | little |

`base-demo.simplelink` başlığı: `Flags: 0x5000200, Version5 EABI, soft-float ABI`

**Madde madde bulgular:**

| Şablon maddesi | Bulgu |
|----------------|-------|
| Hedef platform | 8× `.z1`, 6× `.sky` → MSP430; 1× `.simplelink` → CC1352R/ARM; 1× `.cooja` → x86-64 |
| MSP430 mimari tipi | `readelf`: "Texas Instruments msp430 microcontroller" — 16-bit, MSP430X uzantılı |
| ELF format | `.z1/.sky/.simplelink` = ELF32 **EXEC**; `.cooja` = ELF64 **DYN** (paylaşımlı kütüphane) |
| Endianness | **little-endian** (düşük byte önce) — 16 dosyada da `2's complement, little endian` |
| Entry point | Z1=`0x3100`, Sky=`0x4000`, ARM=`0x6751`, cooja=`0x14b00` |
| ABI | ARM: `Version5 EABI, soft-float ABI`; MSP430: `Flags 0x1000000x` (msp430 EABI) |
| Compiler izi | `.z1/.sky` = msp430-gcc; ARM = `GCC ARM 9.3.1`; cooja = `GCC Ubuntu 11.3.0` |
| Toolchain versiyonu | Contiki-NG `v4.8` (own-*, nullnet-unicast.z1) ve `v4.9-639` (diğerleri) |
| Optimization level | `-Os` (boyut) — Contiki-NG varsayılanı; sıkı/küçük kod bunu gösterir |
| Debug symbol | **Var** — 16 dosyada da 8 adet `.debug_*` bölümü mevcut |

💡 **Yorum:** `readelf -h` bir firmware'in **kimlik kartıdır**. Dört platform net
ayrıştı: `.z1/.sky` 16-bit MSP430, `.simplelink` 32-bit ARM Cortex-M4F (CC1352R),
`.cooja` PC'de koşan 64-bit x86 paylaşımlı kütüphanedir (DYN tipi — Cooja onu `dlopen`
ile yükler). Entry point farkları bellek haritasını yansıtır. ARM'daki **`soft-float
ABI`** önemli bir tercihtir: Cortex-M4**F** donanım FPU'su olmasına rağmen derleyici
yazılım kayan-nokta uzlaşımı seçmiş (kesme bağlamında FPU register'larını kaydetme
maliyetinden kaçınma). Tüm dosyalarda `.debug_*` bölümleri olduğundan bunlar debug
build'dir.

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

**Kullanılan komut:** `size <firmware>` (bölüm boyutları), `readelf -S` (memory map).

| Firmware | text | data | bss | **Flash**=text+data | **RAM**=data+bss |
|----------|------|------|-----|---------------------|------------------|
| `nullnet-broadcast.z1` | 17866 | 166 | 2240 | 18 032 | 2 406 |
| `hello-world.z1` | 41512 | 328 | 5676 | 41 840 | 6 004 |
| `own-udp-server.z1` | 51456 | 390 | 6042 | 51 846 | 6 432 |
| `own-new-firmware.z1` | 71715 | 336 | 5706 | 72 051 | 6 042 |
| `hardworker.z1` | 73564 | 374 | 5698 | 73 938 | 6 072 |
| `hello-world.sky` | 42237 | 324 | 6714 | 42 561 | 7 038 |
| `nullnet-unicast.sky` | 29171 | **4426** | 3086 | 33 597 | 7 512 |
| `base-demo.simplelink` | 71393 | 1408 | 12968 | 72 801 | 14 376 |

**Madde madde bulgular:**

| Şablon maddesi | Bulgu |
|----------------|-------|
| Flash/RAM/Stack/Heap | Flash=kalıcı kod; RAM=çalışma verisi; Stack=çağrı yığını; Heap=dinamik (Contiki'de neredeyse kullanılmaz) |
| Flash kullanımı | `text+data`. En az: `nullnet-broadcast.z1` 18 KB; en çok: `hardworker.z1` 74 KB |
| RAM kullanımı | `data+bss`. 2.4 KB – 14 KB arası. ARM en yüksek (DMA struct'ları) |
| `.text` boyutu | Salt makine kodu + sabitler, Flash'ta. 17 KB – 73 KB |
| `.data` boyutu | Başlangıçlı global'ler. Genelde <500 B; `nullnet-unicast.sky` 4426 B (anormal) |
| `.bss` boyutu | Sıfır başlangıçlı global'ler, sadece RAM. 2–13 KB |
| Stack kullanım tahmini | `size`'da görünmez; `bss` üstü boş RAM'de çalışma anında ayrılır |
| Heap var/yok | MSP430 firmware'lerinde ayrı `.heap` yok; ARM'da `.heap` var (256 B) |
| Section dağılımı | `readelf -S` ile: `.text/.rodata` Flash, `.data/.bss` RAM (bkz. B7) |
| Memory map | Z1: 92 KB Flash/8 KB RAM; Sky: 48 KB/10 KB; CC1352R: 352 KB/80 KB |
| Büyük veri yapısı | `nullnet-unicast.sky` `data=4426 B` → gömülü büyük sabit tablo |

💡 **Yorum:** `size` firmware'in donanıma **sığıp sığmayacağını** gösterir. `text` →
Flash; `data` → hem Flash (ilk değer) hem RAM; `bss` → sadece RAM. Stack ve Heap
`size`'da yoktur çünkü çalışma anında `bss` üstündeki boş RAM'den ayrılırlar. Çarpıcı
fark: `hardworker.z1` 74 KB ile Z1 flash'ının %80'ini doldururken `nullnet-broadcast.z1`
sadece 18 KB kullanır — fark, ağ yığınının ağırlığıdır (bkz. B9). `nullnet-unicast.sky`'ın
4426 B `data`'sı diğer nullnet'lerden ~25× büyük; bu büyük bir gömülü sabit tabloya
işaret eder. Kendi `own-new-firmware.z1`'in 72 KB text'i, içine gömülü OTA payload'undan
gelir.

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

**Kullanılan komut:** `nm -n <firmware>` — sembolleri adrese göre sıralar.
Türler: `T/t`=kod, `D/d`=başlangıçlı veri, `B/b`=bss, `U`=tanımsız, `A`=mutlak.

| Firmware | Toplam | Fonksiyon (T/t) | Tanımsız U | bss B/b | data D/d |
|----------|--------|-----------------|------------|---------|----------|
| `nullnet-broadcast.z1` | 705 | 291 | 15 | 97 | 22 |
| `own-udp-server.z1` | 1059 | 537 | 13 | 185 | 39 |
| `hardworker.z1` | 1039 | 519 | 13 | 172 | 48 |
| `base-demo.simplelink` | 1146 | 761 | 0 | 228 | 53 |
| `mtype5756516.cooja` | 1681 | 1109 | 22 | 415 | 112 |

**Madde madde bulgular** (`own-udp-server.z1` örnek):

| Şablon maddesi | Bulgu |
|----------------|-------|
| Fonksiyon isimleri | `T` sembolleri: 537 fonksiyon (`main`, `cfs_open`, `ota_crc32_buffer`...) |
| Global değişkenler | `D` (başlangıçlı) + `B` (sıfır) büyük harf semboller |
| Static değişkenler | `d`/`b` küçük harf semboller — dosyaya özel (file-scope `static`) |
| ISR fonksiyonları | `cc2420_timerb1_interrupt`, `timera0`, `timera1` |
| Contiki process entry | `udp_server_process` (D), `process_thread_*` (t) |
| Radio driver | `cc2420_*`, `process_thread_cc2420_process` |
| Timer callback | `ctimer_init/set/reset/stop/expired`, `etimer_request_poll` |
| Networking callback | `udp_rx_callback` (kendi kodumuz), `tcpip_*`, `dao_ack_handler` |
| Sensor handler | `process_thread_accmeter_process` (ivmeölçer) |
| Kullanılan kütüphaneler | `rpl_*`, `csma_*`, `cc2420_*`, `cfs_*` sembol kümeleri |
| Dead fonksiyonlar | Contiki `--gc-sections` ile eler; `nm`'deki semboller "canlı" koddur |
| Function address mapping | `nm -n` adrese sıralı: `0x313e main`, `0x725c ota_crc32_buffer` |

💡 **Yorum:** `nm` firmware'in **fonksiyon haritasıdır**. Büyük/küçük harf ayrımı
kritiktir: `T`=global fonksiyon, `t`=static (dosyaya özel) fonksiyon; `D/B`=global
değişken, `d/b`=static değişken. `U` (undefined) normalde linklemede çözülür; ELF'te
kalan birkaç `U` donanım register adresi gibi zayıf/mutlak sembollerdir (ARM'da `U=0`,
linkleme tam kapalı). Kendi OTA alıcımızda `cfs_*` ve `ota_metadata_*` sembollerinin
**bulunması**, Part 1'de yazdığımız depolama kodunun gerçekten linklendiğini kanıtlar.
Contiki `-ffunction-sections + --gc-sections` kullandığından ölü kod zaten elenir.

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

**Kullanılan komut:** `strings <firmware>` — `.rodata` içindeki okunabilir metinleri çeker.

**Madde madde bulgular:**

| Şablon maddesi | Bulunan örnek (gerçek `strings` çıktısı) |
|----------------|------------------------------------------|
| Debug mesajları | `"failed to create a new RPL DAG"`, `"failed to add neighbor"` |
| printf logları | `"Sending from node_id :%d"`, `"Received %u , node_id %d from"` |
| IPv6 adresleri | `"::FFFF:%u.%u.%u.%u"` (IPv4-eşlemeli IPv6 biçim şablonu) |
| MAC adresleri | `"Link-layer address: "`, `"- MAC: %s"` |
| Network node ID | `"Sending from node_id :%d"` — düğüm kimliği basımı |
| Sensor isimleri | `base-demo`: `"batmon-sensor.c"`, `"button-sensor-arch.c"` |
| Process isimleri | `"Hello world process"`, `"[LED] Toggled"`, `"OTA Alici"` |
| Routing protokol | `"RPL Lite"`, `"created a new RPL DAG"` |
| TSCH/6LoWPAN/RPL | `"RPL Lite"`, 6LoWPAN sıkıştırma mesajları; TSCH dizesi **yok** |
| Hidden diagnostic | `"SRH node not found, skip SRH insertion"` |
| Hardcoded config | `"802.15.4 PANID: 0x%04x"`, `"802.15.4 Default channel: %u"` |
| Developer notları | `"Starting Contiki-NG-...v4.9-639"` (sürüm damgası) |

Kendi `own-udp-server.z1`'den: `"=== OTA Alici Hazir ==="`, `"Slot B PENDING: ..."`.

💡 **Yorum:** `strings` **en hızlı keşif aracıdır** — kodu sökmeden firmware'in ne
yaptığını ele verir. `%d %u` biçim belirteçleri çalışma anında basılan değişkenleri
gösterir. `base-demo.simplelink`'teki `batmon-sensor` (pil izleme) ve
`button-sensor-arch` dizeleri donanımın **CC1352 LaunchPad** olduğunu kesinleştirir.
`PANID` ve `channel` dizeleri **hardcoded ağ yapılandırmasını** ele verir. Kendi OTA
mesajlarımızın doğrudan görünmesi, **ELF kullanmanın ham binary'ye üstünlüğüdür** —
ham binary'de hangi byte'ın metin olduğu bilinemezdi.

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

**Kullanılan komut:** `objdump -d <firmware>` — makine kodunu assembly'ye çevirir.

`own-udp-server.z1` komut frekansı (disassembly taraması):
```
calla=1509   jnz=876   jz=763   jmp=756   reta=550
push=300     jnc=132   jc=122   pop=35    br=1
```

MSP430 `main` vs ARM `main` prologue:
```asm
MSP430:  313e <main>:  calla #0x075ca      <- mutlak çağrı
ARM:     a24  <main>:  stmdb sp!, {r4-r8,lr}  <- register'ları stack'e it
                        bl 21c8 <platform_init_stage_one>
```

**Madde madde bulgular:**

| Şablon maddesi | Bulgu |
|----------------|-------|
| Instruction sequence | MSP430'da en sık `calla` (1509) → bol fonksiyon çağrısı, sade akış |
| Prologue/epilogue | MSP430: `push`/`pop`; ARM: `stmdb sp!,{...}` / `ldmia` tek komutla |
| Register kullanımı | MSP430 16 register (r0-r15); ARM `r4-r8` callee-saved + `lr` |
| Stack frame | ARM düzenli (`stmdb` ile blok); MSP430 gerektiği kadar `push` |
| ISR akışı | ISR'ler `reti`/`reta` ile döner; vektör tablosundan çağrılır (B8) |
| Loop yapıları | Geri yönlü koşullu atlama (`jnz`/`jz` → önceki adres) = döngü |
| Branch analizi | `jz`(763)+`jnz`(876)+`jc`+`jnc` = ~1893 koşullu dal |
| Jump table | `br` komutu (1 adet) dolaylı atlama → `switch` jump table izi |
| Function call graph | `calla` hedef adresleri izlenerek çağrı grafiği çıkarılabilir |
| Inline tespiti | `-Os` küçük fonksiyonları inline eder → kaynak fonksiyon ayrı görünmez |
| Compiler optimization | Sıkı kod, ortak alt-ifade eliminasyonu → `-Os` davranışı |
| Delay loop | Sayaç azaltıp sıfırı bekleyen sıkı döngüler (radyo zamanlama) |
| Busy-wait | Donanım register'ı sürekli yoklayan döngü; radyo init dışında nadir |
| Context switching | Contiki kooperatif → ISR dışında klasik bağlam değişimi yok |
| Protothread expansion | `PROCESS_THREAD` → `switch`; `PROCESS_WAIT` → `case` etiketi |
| Scheduler davranışı | `process_run` olay kuyruğunu döner; yığınsız kooperatif |

💡 **Yorum:** `objdump -d` iki mimarinin **komut seti farkını** gösterir. MSP430'da
**`calla`** (20-bit mutlak çağrı) baskın komuttur — sade, doğrudan akış. ARM prologue'u
`stmdb sp!,{r4-r8,lr}` ile tüm callee-saved register'ları **tek komutta** stack'e iter;
bu, ARM'ın stack-frame disiplininin daha düzenli olduğunu gösterir. ~1893 koşullu dal,
firmware'in mantık yoğunluğunu gösterir. Tek `br` komutu, derleyicinin bir `switch`
deyimini **jump table**'a çevirdiğine işaret eder. **Protothread genişlemesi** Contiki'nin
kalbidir: `PROCESS_THREAD` derlenince `switch`, `PROCESS_WAIT` ise `case` olur — process
bir olay beklerken `return` eder, olay gelince `switch` ile **kaldığı yere döner**. Bu,
yığınsız kooperatif zamanlayıcının makine kodundaki izidir.

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

**Kullanılan komut:** `addr2line -f -e <firmware> <adres>`.

```
$ msp430-addr2line -f -e own-udp-server.z1 0x313e 0x725c 0x4c40
main              ??:0
ota_crc32_buffer  ??:0
cfs_open          ??:0
```
16 firmware'in tamamında 8 adet `.debug_*` bölümü mevcut (DWARF debug bilgisi).

**Madde madde bulgular:**

| Şablon maddesi | Bulgu |
|----------------|-------|
| Address → source line | Kısmen: satır `??:0` döndü — kaynak ağacı yok, `.debug_line` yol referansları çözülemedi |
| Function → source file | **Başarılı:** `0x313e → main`, `0x725c → ota_crc32_buffer` (`.symtab` sağlam) |
| ISR → source mapping | ISR adresleri `addr2line` ile fonksiyon adına çevrilebilir |
| Crash address çözümleme | Bir çökme adresi `addr2line` ile fonksiyona indirgenebilir |
| Optimization sonrası mapping | `-Os` inline yaptığından bazı adresler birden çok kaynak satırına denk gelir |
| Inline tespiti | `.debug_info` `DW_TAG_inlined_subroutine` etiketleriyle inline'ı işaretler |

💡 **Yorum:** `addr2line`, bir **çökme adresini** okunabilir konuma çeviren temel
debug aracıdır. Testte adres → **fonksiyon adı** çevirisi başarılı oldu — `.symtab` ve
`.debug_info` sağlam. Ancak **satır numarası** `??:0` döndü: `.debug_line` bölümü
derleme anındaki **kaynak dosya yollarına** referans verir; o kaynak ağacı analiz
makinesinde olmadığı için satır eşlemesi tamamlanamadı. Yani fonksiyon seviyesi her
zaman çalışır, satır seviyesi için **orijinal kaynak kod** gerekir. `objdump -S`
assembly'yi kaynakla iç içe gösterir; yine kaynak ağacı ister. 8 `.debug_*` bölümünün
bulunması, neden `.z1` dosyalarının çalışan koddan büyük olduğunu açıklar (bkz. B18).

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

**Kullanılan komut:** `readelf -S` (bölümler), `readelf -l` (segmentler).

`own-new-firmware.z1` (Z1) bölümleri vs `base-demo.simplelink` (ARM):
```
Z1 :  .far.text 0x10000 | .text 0x3100 | .rodata 0xc870 | .data 0x1100
      .bss 0x1250 | .noinit 0x2898 | .vectors 0xffc0
ARM:  .resetVecs 0x0 | .text 0x40 | .rodata 0x10d14 | .data 0x20001b20 (SRAM)
      .ccfg 0x57fa8 | .bss 0x200020d8 (SRAM) | .heap 0x20005200
```

**Madde madde bulgular:**

| Şablon maddesi | Bulgu |
|----------------|-------|
| ELF header | 52 byte; sınıf/mimari/entry/segment-section sayısı (bkz. B1) |
| Section header | Z1=21, ARM=24, Sky=20 bölüm; her biri ad/adres/boyut/bayrak taşır |
| Program header | LOAD tipi segmentler — donanıma fiilen yüklenecek bloklar |
| Symbol table | `.symtab` + `.strtab` — fonksiyon/değişken adları (B3) |
| Relocation entries | EXEC dosyalarda yok (linklenmiş); `.cooja` DYN'de `.rela.plt` var |
| Debug sections | 8 adet `.debug_*` (info/line/abbrev/frame/str/loc/ranges/aranges) |
| DWARF info | `.debug_info` DWARF formatında — değişken/tür/satır bilgisi |
| Linker-generated metadata | `__bss_start`, `_etext`, `__data_start` gibi linker sembolleri |
| Startup section | `.text` başındaki `_reset_vector__` rutini |
| Vector table | `.vectors` (MSP430) / `.resetVecs` (ARM) — sabit adreste (B8) |
| Initialization routines | `__ctors_start`/`__dtors_start`; `.data` kopyala + `.bss` sıfırla |

💡 **Yorum:** `readelf -S` firmware'in **iç organ haritasıdır**. MSP430'da kod, sabit
ve değişken tek 16-bit uzayda iç içedir; `.vectors` her zaman tepededir. Bazı Z1
dosyalarında **`.far.text`** (`0x10000`) görülür — 64 KB'ı aşan kodu MSP430X genişletilmiş
flash'ına taşır. ARM/CC1352R **tamamen farklı**: Flash `0x0`'dan, SRAM `0x20000000`'dan
başlar — kod ve veri **ayrı fiziksel bloklarda**. ARM'daki **`.ccfg`** (Customer
Configuration) kritiktir: CC1352R ROM bootloader'ı açılışta bunu okuyup boot/debug/flash
koruma ayarlarını belirler. **Section** derleyici detayıdır; **segment (LOAD)** donanıma
yüklenecek bloktur — firmware'i flash'a yazan araç segmentleri kullanır.

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

**Kullanılan komut:** `objdump -d -j .vectors`, `nm` (donanım sembolleri).

| Platform | Vektör tablosu | Adres | Boyut | Vektör |
|----------|---------------|-------|-------|--------|
| Z1 (F2617) | `__ivtbl_32` | `0xFFC0` | 64 B | 32 |
| Sky (F1611) | `__ivtbl_16` | `0xFFE0` | 32 B | 16 |
| CC1352R | `.resetVecs` | `0x0` | 64 B | 16+ |

**Madde madde bulgular:**

| Şablon maddesi | Bulgu |
|----------------|-------|
| Interrupt vector table | Z1: 32 vektör `0xFFC0`; Sky: 16 vektör `0xFFE0`; son 2 byte = RESET |
| GPIO access pattern | `gpio_hal_arch_port_*` sembolleri; port register'larına XOR/yazma |
| Timer interrupt | `timera0`, `timera1`, `cc2420_timerb1_interrupt` ISR'leri |
| UART ISR | `uart0_rx_interrupt` (hardworker.z1) — seri port alma kesmesi |
| Radio interrupt handler | `cc2420_*` ISR — radyo paketi gelince tetiklenen kesme |
| ADC access | `__ADC12MCTL0..8` mutlak register sembolleri (MSP430 12-bit ADC) |
| Sensor polling | `process_thread_accmeter_process` periyodik sensör okur |
| Low-power mode | Contiki boşta CPU'yu LPM'e sokar; `lpm`/uyku sembolleri |
| Clock configuration | `clock_init`, `rtimer_arch_init` açılış zincirinde (B5) |
| MSP430 register erişimi | `nm`'de `A` (mutlak) semboller: `__P1OUT`, `__ADC12MCTL0`, `__UCB0I2CIE` |

💡 **Yorum:** Kesme vektör tablosu **donanım olayları ile yazılım arasındaki köprüdür**.
Z1/Sky farkı çarpıcı: **F2617** 32 kesme kaynağı (`__ivtbl_32`), **F1611** 16 kaynak
(`__ivtbl_16`) — bu, aynı uygulamanın neden farklı `.z1`/`.sky` bellek haritasına sahip
olduğunu açıklar. Her iki MSP430'da tablonun **son 2 byte'ı RESET vektörüdür** ve entry
point'i gösterir. ARM/CC1352R'da tablo uzayın başındadır (`0x0`): ilk kelime stack
pointer, ikinci kelime reset handler — Cortex-M standardı. `nm`'deki `A` (absolute)
semboller (`__ADC12MCTL0`, `__UCB0I2CIE`) doğrudan **donanım register adresleridir** —
firmware bunlara yazarak ADC/I2C/GPIO çevre birimlerini sürer.

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

**Kullanılan komut:** `nm | grep -c <protokol>` (sembol sayımı).

| Firmware | `rpl_*` | `tsch_*` | `nullnet*` | `udp/uip` | `csma*` |
|----------|---------|----------|------------|-----------|---------|
| `own-udp-server.z1` | 70 | 0 | 0 | 106 | 3 |
| `hardworker.z1` | 77 | 0 | 0 | 101 | 5 |
| `nullnet-broadcast.z1` | 0 | 0 | 6 | 1 | 5 |
| `nullnet-unicast.z1` | 0 | 0 | 6 | 1 | 5 |

**Madde madde bulgular:**

| Şablon maddesi | Bulgu |
|----------------|-------|
| Unicast | `nullnet-unicast.*`: `"Sending ... to linkaddr_node_addr"` → tek hedef |
| Broadcast | `nullnet-broadcast.z1`: tüm komşulara yayın; hedef seçme mantığı yok |
| Multicast | `rpl_multicast_addr` sembolü RPL firmware'lerinde — IPv6 çok-noktaya |
| IPv6 stack | `uip_*` (~100 sembol) RPL ailesinde; NullNet'te yok (IP atlanmış) |
| RPL routing | ~70-77 `rpl_*` sembol: DAG, DIO, DAO, rank, neighbor tablosu |
| TSCH scheduler | `tsch_*` = **0** → TSCH kullanılmıyor (bkz. B10) |
| MAC layer | `csma_*` sembolleri — CSMA MAC katmanı tüm dosyalarda |
| Packet buffer | `packetbuf_*`, `queuebuf_*`, `packet_memb` — paket tamponları |
| Neighbor table | `rpl_neighbors`, `ds6_neighbors_struct`, `neighbor_list_list`, `neighbor_memb` |
| Radio transmission | `cc2420_transmit/send` → radyo gönderim akışı |
| Retransmission logic | CSMA katmanı `csma_*` ile yeniden gönderim yapar; bizim OTA'da uygulama seviyesi retry |
| ACK mekanizmaları | `dao_ack_handler` (RPL DAO-ACK); 802.15.4 donanım ACK; bizim OTA: binary ACK |
| CSMA/TSCH farkları | CSMA asenkron (dinle-gönder); TSCH zaman dilimli + kanal atlamalı |
| Contiki network API | `NETSTACK_*`, `simple_udp_*`, `uip_*` — Contiki ağ API'si |

💡 **Yorum:** Sembol sayımı firmware'in **ağ mimarisini** ele verir. İki aile var:
**(1) IPv6/RPL ailesi** (~70 `rpl_*`, ~100 `uip_*`) — tam 6LoWPAN+RPL+UDP yığını;
**(2) NullNet ailesi** (`nullnet=6`, `rpl=0`) — IP yığınını atlayıp ham MAC üzerinden
gönderir, bu yüzden çok küçüktür. `unicast` tek hedefe, `broadcast` tüm komşulara
gönderir. **TSCH hiçbir dosyada yok** → tümü CSMA MAC kullanır. Neighbor table
(`rpl_neighbors`, `ds6_neighbors_struct`) ve packet buffer (`packet_memb`) sembollerinin
bulunması, RPL firmware'lerinin komşu yönetimi ve paket tamponlama yaptığını gösterir.
Bizim OTA alıcımızdaki 106 `uip` sembolü, stop-and-wait ACK protokolünün UDP üstüne
kurulduğunu doğrular.

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

**Kullanılan komut:** `nm | grep tsch`.
```
16 firmware'in tamamında tsch_ sembol sayısı = 0
Bunun yerine: csma_ sembolleri tüm dosyalarda mevcut
```

**Madde madde bulgular:**

| Şablon maddesi | Bulgu |
|----------------|-------|
| TSCH slot operation | `tsch_slot_operation` sembolü **yok** — TSCH kullanılmıyor |
| Channel hopping | Kanal atlama mantığı yok — CSMA tek kanalda çalışır |
| ASN handling | ASN (Absolute Slot Number) sembolü yok |
| Radio timing loops | CSMA'da kanal dinleme (CCA) var; TSCH slot zamanlaması yok |
| Synchronization | TSCH saat senkronizasyon rutinleri yok |
| Schedule management | TSCH çizelge yönetimi yok — CSMA çizelgesiz |
| Packet timing | CSMA: rastgele backoff; TSCH: sabit slot — burada CSMA |
| MAC timing critical path | CSMA CCA (Clear Channel Assessment) kritik yoldur |
| Drift compensation | TSCH saat kayması telafisi yok (CSMA gerektirmez) |
| Low-power radio | CSMA radyoyu daha uzun açık tutar; TSCH duty-cycle daha düşük olurdu |

💡 **Yorum:** Analiz edilen **16 firmware'in hiçbirinde TSCH sembolü yok** — bu eksik
bir bulgu değil, anlamlı bir **tespittir**: tümü MAC katmanı olarak **CSMA** kullanır.
Fark şudur: **CSMA** asenkrondur — düğüm göndereceği zaman kanalı dinler (CCA), boşsa
gönderir; basittir ama radyoyu uzun açık tutabilir. **TSCH** zaman dilimli + kanal
atlamalıdır — düğümler ortak çizelgede (ASN) senkronize olur, her slotta farklı kanala
atlar; bu hem **enerji verimliliği** (radyo yalnız kendi slotunda açık) hem **parazit
dayanıklılığı** sağlar ama saat senkronizasyonu (drift compensation) gerektirir. Bu
repodaki örnekler eğitim/demo amaçlı olduğundan basitlik için CSMA seçilmiştir.

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

**Kullanılan komut:** `nm | grep -iE 'led|button|uart|spi|i2c|adc'`.

`hardworker.z1` çevre birimi sembolleri:
```
i2c_tx_interrupt   i2c_rx_interrupt   uart0_rx_interrupt
i2c_receiveinit    i2c_transmitinit   i2c_busy   i2c_enable
led_process        led_timer          button_hal_button_count (U)
accmeter_process   __ADC12MCTL0..8
```

**Madde madde bulgular:**

| Şablon maddesi | Bulgu |
|----------------|-------|
| Button handler | `button_hal_button_count`, `button_hal_buttons` (U — platform HAL'inde) |
| LED driver | `led_process`, `led_timer`; `strings`: `"[LED] Toggled"` |
| UART usage | `uart0_rx_interrupt` — seri port alma kesmesi (log çıktısı için) |
| SPI access | `spi_arch_has_lock` — SPI (radyo CC2420 SPI üzerinden sürülür) |
| I2C access | `i2c_enable/busy/receiveinit/transmitinit/receive_n` — tam I2C sürücü |
| ADC routines | `__ADC12MCTL0..8` — MSP430 12-bit ADC kontrol register'ları |
| Sensor polling interval | `accmeter_process` etimer ile periyodik ivmeölçer okur |
| Interrupt-driven sensor | `i2c_rx_interrupt` — sensör verisi kesme ile alınır |
| GPIO toggle | LED yak/söndür = `xor.b #bit, &PxOUT` (port register'a XOR) |
| Peripheral init sequence | `platform_init`: clock → GPIO → SPI/radyo → sensör (B5) |

💡 **Yorum:** Çevre birimi sembolleri firmware'in **donanımla nasıl etkileştiğini**
gösterir. `hardworker.z1` zengin bir profil sergiler: I2C sürücüsü (`i2c_*` — Z1
üzerindeki TMP102 sıcaklık / ADXL345 ivmeölçer I2C üzerinden bağlı), UART (`uart0_rx_interrupt`
— log için), ADC (`__ADC12MCTL*`), LED (`led_process`) ve buton. `button_hal_*`'ın
**`U` (tanımsız)** olması, buton HAL'inin platform katmanında tanımlı olup uygulama
tarafından referans alındığını gösterir. `base-demo.simplelink` ise CC1352R LaunchPad'in
`batmon-sensor` ve `button-sensor` sürücülerini içerir. GPIO toggle, port register'a XOR
yazma kalıbıyla yapılır. Çevre birimi başlatma `platform_init` zincirinde clock'tan
sensöre doğru ilerler.

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

**Kullanılan komut:** `nm | grep -iE 'mul|div|crc|__mspabi'`.

`own-udp-server.z1` matematik rutinleri (gerçek `nm` çıktısı):
```
__mulsi3      <- 32-bit yazılım çarpma
__udivhi3     <- 16-bit yazılım bölme
__udivsi3     <- 32-bit yazılım bölme
__udivdi3     <- 64-bit yazılım bölme
__udivmoddi4  <- 64-bit böl+mod
ota_crc32_buffer  <- CRC32 (polinom 0xEDB88320)
```

**Madde madde bulgular:**

| Şablon maddesi | Bulgu |
|----------------|-------|
| Floating-point | `float`/`double` rutini görülmedi — ağ kodu kayan nokta kullanmaz |
| Fixed-point | Sayaç/offset hesapları tamsayı (integer) — fixed-point benzeri |
| Trigonometric | `sin/cos` vb. yok — sinyal işleme uygulaması değil |
| Multiply/divide | `__mulsi3`, `__udivhi3/si3/di3` — **yazılım çarpma/bölme rutinleri** |
| Software FP emulation | MSP430'da donanım FPU yok; `float` olsaydı `__mspabi_*f` çağrılırdı |
| DSP benzeri loop | Sıkı DSP döngüsü yok — sadece CRC bit-kaydırma döngüsü |
| Matrix operation | Matris işlem izi yok |
| Signal processing | Sinyal işleme deseni yok |
| Computational hotspot | Tek anlamlı hesap bloğu: `ota_crc32_buffer` (byte başına 8 iterasyon) |
| Numerical optimization | `-Os` çarpma/bölmeyi mümkünse kaydırmaya çevirir |

💡 **Yorum:** Bu firmware ailesi **DSP/ağır matematik uygulaması değildir** — gömülü
ağ düğümleri olduklarından hesaplama yükü düşüktür. Kritik bir bulgu: `nm` çıktısında
**`__mulsi3`, `__udivhi3`, `__udivsi3`, `__udivdi3`** rutinleri görüldü. Bunlar
MSP430'un **donanım çarpma/bölme birimi sınırlı olduğu için** derleyicinin eklediği
**yazılım emülasyon rutinleridir** — 32/64-bit çarpma ve bölme C kodunda yazılımla
yapılır (pahalıdır). ARM tarafında da `__udivmoddi4` görülür (Cortex-M çekirdek
donanım `udiv`'e sahiptir ama 64-bit bölme yine yazılımladır). **Kayan nokta:** hiçbir
`float` rutini yok — eğer olsaydı MSP430'da `__mspabi_mpyf` gibi emülasyon eklenirdi.
Tek anlamlı algoritmik blok kendi OTA alıcımızdaki **`ota_crc32_buffer`** — Part 1'de
yazdığımız, her byte için 8 bit-kaydırma + XOR yapan bütünlük hesabıdır.

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

`msp430-gprof` **çalışma anı profili** gerektirir; statik `.z1`'den üretilemez.
Bunun yerine `size` + `nm` + `objdump` ile **statik göstergeler** kullanıldı.

**Madde madde bulgular:**

| Şablon maddesi | Bulgu |
|----------------|-------|
| Low-power mode geçişleri | Contiki boşta CPU'yu LPM'e sokar; `lpm_*` sembolleri |
| CPU-intensive fonksiyonlar | `ota_crc32_buffer` (CRC döngüsü), `__udivdi3` (64-bit bölme) |
| Busy-wait detection | Radyo init dışında yaygın busy-wait yok (`objdump` taraması) |
| Sleep/wakeup flow | Olay kuyruğu boşalınca uyku; etimer/kesme ile uyanış |
| Timer usage intensity | `etimer`/`ctimer` sembolleri — periyodik uyanma yoğunluğu |
| Radio duty cycle | CSMA → radyo göreli uzun açık; en büyük enerji kalemi |
| ISR yoğunluğu | Z1 32, Sky 16 kesme vektörü; aktif ISR sayısı firmware'e göre değişir |
| Function execution cost | `objdump` komut sayısı ile kabaca tahmin (B5: calla=1509) |
| Flash/RAM efficiency | En verimli `nullnet-broadcast.z1` (18 KB); en yoğun `hardworker.z1` (74 KB) |
| Energy-heavy bölgeler | CRC32 döngüsü + radyo gönderimi en pahalı işlemlerdir |

💡 **Yorum:** Gerçek güç profili ölçüm donanımı veya enstrümante yapı gerektirir;
örnek firmware'ler öyle derlenmediğinden `gprof` **uygulanamadı** (dürüstçe belirtilir).
Ancak statik analiz güçlü ipuçları verir: Contiki'nin olay-güdümlü zamanlayıcısı iş
kalmayınca CPU'yu **LPM**'e sokar — `lpm`/uyku sembolleri ve `etimer/ctimer` kullanımı
uyanma sıklığını gösterir. **Busy-wait** enerji düşmanıdır; örneklerde radyo init
dışında nadir görüldü. **Flash/RAM verimliliği:** `nullnet-broadcast.z1` en verimli,
`hardworker.z1` en yoğun — adı zaten yoğun iş yükünü ima eder. Radyo **duty cycle**'ı
CSMA ile yönetilir ve en büyük enerji kalemidir.

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

`gcov`/`gprof` **enstrümante yapı + çalışma anı verisi** gerektirir:
- `gcov`: kaynak `-fprofile-arcs -ftest-coverage` ile derlenip çalıştırılmalı (`.gcda`).
- `gprof`: kaynak `-pg` ile derlenip `gmon.out` üretmeli.

Örnek `.z1/.sky/.simplelink` dosyaları bu bayraklarla derlenmedi → **komut tabanlı
çıktı üretilemez.** Bunun yerine **statik alternatifler** kullanıldı:

**Madde madde bulgular:**

| Şablon maddesi | Bulgu (statik alternatif) |
|----------------|---------------------------|
| Function call frequency | `objdump -d` ile `calla` hedefleri sayılarak statik tahmin |
| Execution hotspot | CRC32 döngüsü + radyo gönderimi en sık çalışan bölgeler |
| Unused branch | Contiki `--gc-sections` ölü dalları zaten eler |
| Rarely executed path | Hata işleme dalları (`failed to ...`) nadir çalışır |
| Test coverage | `gcov` gerektirir — örneklerde uygulanamaz |
| Critical execution path | OTA'da: chunk gönder → ACK bekle (Part 1 Cooja log'larında gözlendi) |
| Runtime bottleneck | `gprof` gerektirir — Cooja simülasyon log'u kısmi runtime trace sağlar |

💡 **Yorum:** Coverage/profiling **dinamik analiz** kategorisindedir — statik bir
firmware imajından elde edilemez; uygulanamaması beklenen bir durumdur ve dürüstçe
belirtilir. Yine de **yöntem** açıklanabilir: `gcov` hangi satır/dalın çalıştığını
sayar → test kapsamı ve ölü dallar bulunur; `gprof` fonksiyon çağrı sıklığı/süresini
ölçer → hotspot ve darboğazlar tespit edilir. Gömülü sistemlerde bunlar genelde Cooja'da
veya seri port log'uyla yapılır. **Statik alternatif:** çağrı grafiği `objdump -d` ile
çıkarılabilir; Part 1 simülasyonumuzdaki Cooja log'ları (her bloğun gönder/ACK satırı)
fiilen bir **runtime trace** işlevi görmüş, protokolün kritik yolu gözlemlenmiştir.

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

**Yöntem:** `readelf` → kimlik, `strings` → amaç, `nm` → alt sistemler, `objdump` →
mantık. `nullnet-unicast.z1` üzerinde uygulandı.

**Madde madde bulgular:**

| Şablon maddesi | Bulgu (`nullnet-unicast.z1`) |
|----------------|------------------------------|
| Firmware behavior recovery | `strings` → "Sending from node_id, to linkaddr" → nokta-nokta gönderim |
| Unknown firmware classification | `readelf -h` → MSP430 Z1 mote firmware'i |
| Feature inference | `nm` → `nullnet`, `csma` var; `rpl`, `udp` yok → minimal ağ |
| Protocol inference | NullNet + CSMA → IP'siz ham MAC haberleşmesi |
| ISR purpose discovery | `cc2420_*` ISR → radyo; `timera*` → zamanlayıcı |
| Hardware interaction | `cc2420` radyo + SPI; LED/buton sembolleri |
| State machine extraction | `process_thread_*` switch/case → protothread durum makinesi |
| Scheduler reconstruction | `process_run` olay kuyruğu → kooperatif zamanlayıcı |
| Event-flow reconstruction | radyo ISR → packetbuf → process olayı → uygulama callback |
| Network role inference | `linkaddr_node_addr` hedefli → unicast gönderici/alıcı düğüm |

💡 **Yorum:** Reverse engineering, **dokümantasyonsuz bir firmware'in ne yaptığını**
araç zinciriyle çıkarmaktır. Dört adımlı yöntemle `nullnet-unicast.z1`'in rolü çıkarıldı:
`rpl=0` → yönlendirme yok; `nullnet` sembolleri → ham MAC; string → belirli hedefe
(`linkaddr_node_addr`) gönderim → sonuç: **nokta-nokta unicast demo'su**. `broadcast`
sürümü tüm komşulara yayın yapar ve daha küçüktür. **Ağ rolü çıkarımı** kendi
firmware'lerimizde de işler: `own-udp-server.z1`'de `NETSTACK_ROUTING.root_start` +
`cfs_*` → **DAG kökü + OTA alıcı**; `own-udp-client.z1`'de `firmware_payload` → **OTA
gönderici**. Detaylı tam vaka için bkz. B23.

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

Contiki-NG varsayılan `-Os` (boyut) kullanır. Part 1 projemizde de `Makefile`'a
`CFLAGS += -Os` eklendi — somut bir nedenle:
```
Sorun : msp430-gcc 4.7.4, -O0'da "undefined reference to mac_call_sent_callback"
Neden : Eski derleyici -O0'da `static inline` fonksiyonun yerel kopyasını üretmiyor
Çözüm : -Os optimizer inline'ı zorlar → sembol çözülür
```

**Madde madde bulgular:**

| Şablon maddesi | Bulgu |
|----------------|-------|
| `-O0/-O2/-Os` farkları | `-O0` büyük/yavaş/debug-dostu; `-Os` küçük (Contiki tercihi); `-O2` hızlı |
| Inlining behavior | `-Os` küçük fonksiyonları çağırana gömer → `nm`'de ayrı görünmez |
| Dead code elimination | `-ffunction-sections + --gc-sections` ile kullanılmayan kod atılır |
| Constant folding | Derleyici sabit ifadeleri derleme anında hesaplar |
| Loop optimization | Döngü değişmezleri dışarı alınır; sayaçlar register'da tutulur |
| Register allocation | MSP430 16, ARM 16 register; sık değişkenler register'a atanır |
| Tail-call optimization | Son çağrı `calla` yerine `br`/`jmp`'e çevrilebilir |
| Branch optimization | Koşullu dallar yeniden sıralanır; ~1893 dal (B5) |
| Macro expansion | `PROCESS_THREAD`, `LOG_INFO` makroları `cpp` ile genişler |
| Preprocessor etkileri | `#if WITH_SERVER_REPLY` gibi koşullu derleme kod boyutunu etkiler |

💡 **Yorum:** Optimizasyon seviyesi firmware'in hem **boyutunu** hem **derlenebilmesini**
etkiler. `-O0` birebir kaynağa benzer, debug kolaydır ama büyüktür; `-Os` kod boyutunu
küçültür — sınırlı flash için idealdir, Contiki-NG tercihidir; `-O2` hız odaklıdır. Bu
projede `-O0 → -Os` geçişi bir tercih değil **zorunluluktu**: eski msp430-gcc 4.7.4,
`-O0`'da `static inline` fonksiyonlar için yerel kopya üretmediğinden linker hatası
veriyordu; `-Os` inline'ı gerçekleştirince sorun çözüldü — bu, **derleyici
optimizasyonunun derleme başarısını dahi etkileyebileceğinin** somut kanıtıdır. `-Os`
ayrıca **dead-code elimination** ve **inlining** yapar; bu yüzden bazı kaynak fonksiyonu
disassembly'de ayrı görünmez. `PROCESS_THREAD` gibi makrolar preprocessor ile genişler.

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

**Kullanılan komut:** `readelf -S` (yerleşim), `readelf -l` (segment eşleme).

| Bölüm | Z1 | Sky | ARM |
|-------|-----|-----|-----|
| `.text` | `0x3100` | `0x4000` | `0x40` |
| `.data` | `0x1100` (RAM) | `0x1100` (RAM) | `0x20001b20` (SRAM) |
| `.vectors` | `0xFFC0` | `0xFFE0` | `0x0` |

**Madde madde bulgular:**

| Şablon maddesi | Bulgu |
|----------------|-------|
| Section placement | Linker script `.text/.data/.vectors`'ı platforma özel sabit adrese koyar |
| Link order | Nesne dosyaları belirli sırada linklenir; başlangıç kodu en başta |
| Static library linkage | Contiki-NG yeni build sistemi `.o`'ları doğrudan linkler (B19) |
| Startup code | `.text` başındaki `_reset_vector__` — `.data` kopyala, `.bss` sıfırla |
| Linker script behavior | `.vectors`'ı `0xFFC0`/`0xFFE0`'a **zorla** yerleştirir |
| Vector placement | MSP430: flash tepesi; ARM: flash başı (`0x0`) — donanım dayatması |
| Symbol resolution | Tüm `U` semboller linkleme aşamasında çözülür |
| Relocation behavior | EXEC dosyada yok (mutlak adresli); `.cooja` DYN'de relocation var |

💡 **Yorum:** **Linker (`ld`)** nesne dosyalarını birleştirip her bölümü **donanımın
beklediği fiziksel adrese** yerleştirir; bu, platforma özel **linker script** ile
dikte edilir. En kritik örnek **`.vectors`**'tür: MSP430 donanımı reset vektörünü
**her zaman** flash tepesinde (`0xFFFE`) arar; linker script `.vectors`'ı oraya **zorla**
koyar — bir byte şaşsa cihaz boot etmez. `.text` Z1'de `0x3100`, Sky'da `0x4000`'dedir
çünkü flash başlangıçları farklıdır. **Startup code** (`_reset_vector__`) `.data`'yı
flash'tan RAM'e kopyalar, `.bss`'i sıfırlar, sonra `main`'i çağırır. **Symbol resolution:**
linker tüm `U` sembollerini çözer; çözemezse "undefined reference" hatası verir —
Part 1'deki `mac_call_sent_callback` hatamız tam buydu (B16).

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

**Kullanılan komut:** `objcopy`, `strip`. `own-udp-server.z1` üzerinde canlı test:
```
$ msp430-objcopy -O ihex   own-udp-server.z1 fw.hex   ->  145 872 byte
$ msp430-objcopy -O binary own-udp-server.z1 fw.bin   ->   52 992 byte
$ msp430-strip             own-udp-server.z1 -o fw-stripped.z1 -> 52 572 byte
  Orijinal ELF: 112 920 byte
```

**Madde madde bulgular:**

| Şablon maddesi | Bulgu |
|----------------|-------|
| ELF → HEX | `objcopy -O ihex` → 145 872 B (metin: adres+veri+checksum, en büyük) |
| ELF → binary | `objcopy -O binary` → 52 992 B (sadece byte'lar, adres bilgisi yok) |
| Section extraction | `objcopy -j .text` ile tek bölüm ayıklanabilir |
| Symbol stripping | `strip` `.symtab`/`.strtab`'ı atar |
| Debug removal | `strip` 8 `.debug_*` bölümünü atar → 112 KB'tan 52 KB'a |
| Firmware minimization | `strip` ile boyut **%54 azaldı** — debug bilgisi çıkarıldı |
| Binary patch preparation | `.bin` ham byte → offset bazlı yama hazırlanabilir (OTA chunk'ı gibi) |

💡 **Yorum:** `objcopy`/`strip` bir firmware'i **formattan formata çevirir**. Çarpıcı
bulgu: `strip` ile ELF **112 KB → 52 KB**'a düştü — dosyanın **yarısından fazlası debug
bilgisi ve sembol tablosuydu** (`.debug_*`, `.symtab`). Bu, neden `.z1` dosyalarının
çalışan koddan büyük olduğunu kesinleştirir. **Ham binary** (`.bin`, 52 KB) en küçüğüdür
ama **adres bilgisi taşımaz**. **Intel HEX** (`.hex`, 144 KB) en büyüğüdür çünkü
metindir: her satır `:` + uzunluk + adres + veri + checksum içerir — programlayıcı
araçların tercihidir çünkü her satırda hedef adres ve bütünlük checksum'u taşır. **OTA
bağlamı:** Part 1'de biz de firmware'i bloklara bölüp her bloğa offset + checksum
ekledik; `objcopy`'nin HEX üretmesi kavramsal olarak bizim chunk protokolümüzle aynı
işi yapar. `strip` ise OTA öncesi firmware'i küçültmek için kullanılır — daha az byte
= daha hızlı kablosuz transfer.

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

```
$ find build -name "*.a"
(sonuç yok — Contiki-NG yeni build sistemi tek .a arşivi üretmez)
$ ls build/z1/obj/
*.o nesne dosyaları doğrudan linkleniyor
```

**Madde madde bulgular:**

| Şablon maddesi | Bulgu |
|----------------|-------|
| Static library içeriği | `.a` arşivi = `.o` nesne dosyalarının `ar` paketi; örneklerde `.a` yok |
| Object file extraction | `ar x lib.a` ile `.o` çıkarılır — burada `build/z1/obj/*.o` zaten ayrık |
| Archive symbol table | `ranlib` arşive sembol indeksi ekler; `nm -s lib.a` ile okunur |
| Linked module analizi | `nm`'deki `rpl_*`, `csma_*`, `cc2420_*` kümeleri linklenen modülleri gösterir |

💡 **Yorum:** Bir **statik kütüphane (`.a`)**, derlenmiş `.o` nesne dosyalarının `ar`
ile paketlenmiş halidir — `ar t` içeriği listeler, `ar x` çıkarır, `ranlib` sembol
indeksi kurar. Ancak analiz edilen firmware'ler **nihai linklenmiş çalıştırılabilir
dosyalardır** — kütüphaneler içlerinde eritilmiştir; `.z1`'e `ar` uygulanamaz. Ayrıca
Contiki-NG'nin yeni Make build sistemi eski `contiki-ng-z1.a` arşivini **üretmez** —
nesne dosyalarını (`build/z1/obj/*.o`) linker'a doğrudan verir ve `--gc-sections` ile
kullanılmayanları eler. Bu bölüm örnek firmware'ler için **doğrudan uygulanamaz**;
yöntem yine geçerlidir. Linklenmiş modüllerin **izleri** `nm` çıktısında görülür:
`rpl_*`, `csma_*`, `cc2420_*` sembol kümeleri hangi kütüphane modüllerinin firmware'e
dahil edildiğini ele verir.

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

`hardworker.z1` process sembolleri (`nm`):
```
accmeter_process  cc2420_process   ctimer_process   etimer_process
led_process       sensor_process   udp_process      tcpip_process
dummy_printer_process   sensors_process   stack_check_process
```

**Madde madde bulgular:**

| Şablon maddesi | Bulgu |
|----------------|-------|
| PROCESS_THREAD recovery | `process_thread_*` (t) sembolleri — her process'in iş parçacığı |
| Protothread expansion | `PROCESS_THREAD` → `switch(pt->lc)`; `PROCESS_WAIT` → `case` |
| Event-driven scheduler | `process_run` olay kuyruğunu döner — kooperatif zamanlayıcı |
| etimer/ctimer usage | `etimer_process`, `ctimer_process` + `ctimer_set/reset/expired` |
| PROCESS_BEGIN/END | `BEGIN` switch'i açar, `END` kapatır — yanlış yer = derleme hatası |
| PROCESS_YIELD flow | `YIELD` → `return PT_YIELDED`; olayla kaldığı `case`'e döner |
| NETSTACK interaction | `cc2420_process` → `tcpip_process` zinciri (radyo → IP) |
| Packetbuf lifecycle | `packetbuf_*` — gelen paket tamponlanır, işlenir, temizlenir |
| uIP callback chain | `tcpip_process` → `udp_rx_callback` çağrı zinciri |
| Rime stack usage | Rime kullanılmıyor — modern Contiki-NG NETSTACK + uIP kullanır |

💡 **Yorum:** Contiki-NG'nin kalbi **protothread (yığınsız iş parçacığı)** modelidir.
Her `PROCESS(...)` makrosu RAM'de bir **`struct process`** oluşturur — `nm`'de process'ler
`D` sembolü, hepsi `0x1100` civarında (RAM başı) kümelenir. `hardworker.z1`'de **11
process** bulunması firmware'in çok-görevli olduğunu gösterir. **PROCESS_THREAD**
derlenince `switch(process_pt->lc)` olur; **BEGIN/END** switch'i açıp kapatır;
**WAIT/YIELD** bir `case` üretir — process olay beklerken `return` eder, olay gelince
`switch` ile **tam kaldığı `case`'e döner**. Part 1'de bu inceliği yaşadık: erken
`PROCESS_END()` switch'i erken kapattığı için "case label not within switch" hatası
aldık. **etimer/ctimer** olay-güdümlü zamanlayıcının çekirdeğidir. **`stack_check_process`**
RAM yığın taşmasını izleyen güvenlik process'idir (B21).

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

**Kullanılan komut:** `strings | grep -iE 'password|key|secret|token'`.
```
$ for fw in firmware-samples/*; do strings $fw | grep -iE 'password|secret|key=' ; done
(sonuç yok — hardcoded gizli bilgi bulunamadı)
```

**Madde madde bulgular:**

| Şablon maddesi | Bulgu |
|----------------|-------|
| Hardcoded credential | **Bulunamadı** — 16 dosyada parola/anahtar dizesi yok |
| Debug backdoor izleri | Gizli debug komutu/backdoor dizesi görülmedi |
| Buffer handling | Kendi OTA kodumuz `datalen` kontrolü yapar (boyut doğrulanır) |
| Unsafe memory access | `memcpy` öncesi `payload_len` sınırı kontrol edilir |
| Stack-heavy routines | Büyük yerel dizi kullanan rutin görülmedi (`size` `bss` makul) |
| Potential overflow | OTA paketinde `datalen != HEADER_LEN+payload_len` ile taşma engellenir |
| Assert/debug remnants | `strings`'te dosya/satır içeren debug mesajları (`"failed to ..."`) kalmış |
| Information leakage | Sürüm dizesi (`Contiki-NG v4.9`) ve `.debug_*` bilgi sızdırır → `strip` önerilir |

💡 **Yorum:** Güvenlik analizinin ilk adımı **hardcoded gizli bilgi** aramaktır —
parola, API anahtarı, debug arka kapısı. Taranan 16 firmware'de böyle bir sızıntı
**bulunmadı** (hepsi eğitim/demo firmware'idir). **Buffer handling:** gömülü C'nin en
büyük riski tampon taşmasıdır; kendi Part 1 kodumuzda bunu bilinçle ele aldık — OTA
alıcı her paket için `datalen < HEADER_LEN` ve `datalen != HEADER_LEN+payload_len`
kontrolü yapar, yani **boyut doğrulanmadan belleğe yazmaz**. **Bütünlük:** OTA
protokolümüz blok başına XOR checksum + tüm imaj için CRC32 kullanır. **`stack_check_process`**
(hardworker.z1), RAM yığınına imza yazıp periyodik kontrol eden **yığın taşması
dedektörüdür** — 8 KB RAM'li cihazda yığın/heap çakışması ciddi risktir. **Assert
kalıntıları:** debug mesajları saldırgana kod yapısı sızdırabilir; üretim firmware'inde
`strip` ile temizlenmeleri önerilir (B18). ARM/CC1352R'da `.ccfg` JTAG/debug kilidini
kontrol eder — üretimde debug arayüzünün kapatılması kritiktir.

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
| `nullnet-unicast.sky` | Sky | 33 597 | 7 512 | 300 | NullNet+CSMA | — |
| `hello-world.z1` | Z1 | 41 840 | 6 004 | 502 | RPL+UDP+CSMA | 15 463 |
| `hello-world.sky` | Sky | 42 561 | 7 038 | 474 | RPL+UDP+CSMA | — |
| `udp-client.z1` | Z1 | 42 878 | 6 224 | 510 | RPL+UDP+CSMA | — |
| `own-udp-client.z1` | Z1 | 50 745 | 6 330 | 512 | RPL+UDP+CSMA | — |
| `own-udp-server.z1` | Z1 | 51 846 | 6 432 | 537 | RPL+UDP+CFS | 18 595 |
| `own-new-firmware.z1` | Z1 | 72 051 | 6 042 | 530 | RPL+UDP | — |
| `hardworker.z1` | Z1 | 73 938 | 6 072 | 519 | RPL+UDP+sensör | — |
| `base-demo.simplelink` | CC1352R | 72 801 | 14 376 | 761 | RPL+UDP+sensör | 27 897 |
| `mtype5756516.cooja` | x86-64 | — | — | 1109 | RPL+UDP | — |

**Madde madde bulgular:**

| Şablon maddesi | Bulgu |
|----------------|-------|
| Code size farkı | NullNet 18 KB ↔ hardworker 74 KB — RPL eklemek ~24 KB flash maliyeti |
| RAM farkı | 2.4 KB (nullnet-broadcast) ↔ 14 KB (base-demo ARM) |
| Function count farkı | 291 (en sade) ↔ 1109 (cooja-native, en zengin) |
| ISR yoğunluğu | Z1 32 vektör, Sky 16 vektör — donanım kaynaklı |
| Networking complexity | İki aile: NullNet (minimal) ↔ RPL+UDP (tam IPv6 yığını) |
| Radio stack farkı | MSP430: CC2420 radyo; CC1352R: dahili SimpleLink radyo |
| Symbol farkı | Aynı uygulama farklı platformda ±%10 sembol; fark HAL'den gelir |
| Optimization farkı | Hepsi `-Os` — optimizasyon farkı yok; fark uygulama kapsamından |
| Assembly complexity | nullnet-broadcast 6 585 satır ↔ base-demo 27 897 satır disasm |

💡 **Yorum:** Karşılaştırmalı analiz firmware'ler arası **mimari ve uygulama farklarını**
sayısallaştırır. **Ağ yığını en büyük belirleyicidir:** NullNet firmware'leri (18–33 KB)
IPv6/RPL'i atladıkları için RPL+UDP'lilerin (42–74 KB) yarısı kadardır. **Platform
farkı:** aynı `hello-world` Z1'de 41 840 B, Sky'da 42 561 B — kod neredeyse aynı, fark
HAL'den; Sky daha çok RAM harcar. **En karmaşık** `base-demo.simplelink` (761 fonksiyon,
27 897 satır disasm) — ARM komut seti geniş, CC1352R çok çevre birimi içerir. **Hepsi
`-Os`** ile derlendiğinden optimizasyon farkı yok; fark tamamen **uygulama kapsamından**
gelir. Kendi `own-udp-server.z1` (537 fonk., CFS dahil), `own-udp-client.z1`'den (512)
biraz büyük — alıcı Coffee dosya sistemi + OTA metadata kodunu ek taşır.

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

Hiçbir dokümantasyonu yokmuş gibi, sadece araç zinciriyle çözümlendi:
```
readelf -h → ELF32, MSP430, entry 0x3100  → Z1 mote firmware'i
strings    → "Contiki-NG v4.9-639", "[LED] Toggled", "LED Toggle P.ID:03"
nm         → 11 process: led/accmeter/sensor/udp/tcpip/dummy_printer...
nm         → rpl=77, udp=101, tsch=0
```

**Madde madde bulgular:**

| Şablon görevi | Çıkarım |
|---------------|---------|
| Ne yaptığını bulma | Çok-process'li yoğun IoT düğümü ("hardworker" = çok çalışan) |
| Hangi protokol | RPL + UDP + 6LoWPAN, CSMA MAC (`rpl=77`, `tsch=0`) |
| button/LED mapping | `led_process` + `led_timer`; `"LED Toggle P.ID:03"` → process ID 3 LED'i sürer |
| ISR'leri tanıma | `cc2420_*`=radyo, `timera0/1`=zamanlayıcı, `uart0_rx`=seri, `i2c_*`=sensör |
| network role çıkarımı | RPL düğümü; `rpl_dag_root` çağrısına göre kök/yaprak ayrılır |
| algoritmik blok | Ağır hesap yok; periyodik sensör okuma + paket üretimi |
| energy-heavy bölgeler | Radyo gönderimi + sürekli sensör polling (`accmeter_process`) |
| stripped firmware | `strip`'lenseydi sembol adları kaybolurdu; `strings`+`objdump` ile yine çözülürdü |

💡 **Yorum:** Bu vaka araç zincirinin **gücünü kanıtlar** — kapalı bir binary, doğru
araçlarla **tamamen şeffaf** hale gelir. Hiç kaynak koda bakmadan `readelf`+`nm`+`strings`
üçlüsüyle `hardworker.z1`'in tam profili çıkarıldı: bir **Z1 mote** üzerinde koşan,
**11 process'li yoğun IoT düğüm** firmware'i. **Davranışı:** `led_process` LED'i
periyodik yakar (`"[LED] Toggled"`); `accmeter_process` + `sensor_process` ivmeölçer/
sensör okur (I2C üzerinden); `udp_process` RPL ağında UDP paketi gönderir
(`"failed to create packet, seqno"` → sıra numaralı üretim); `dummy_printer_process`
debug basar; `stack_check_process` RAM'i korur. **ISR tanıma:** `cc2420_*` radyo,
`timera*` zamanlayıcı, `uart0_rx_interrupt` seri, `i2c_*` sensör kesmeleri. **Ağ rolü:**
`rpl=77` → bir RPL düğümü. 74 KB flash + 11 process ile repodaki **en yoğun firmware**dir
— adı bunu doğrular. Aynı yöntem `strip`'lenmiş bir firmware'e uygulansaydı sembol
adları kaybolurdu; o zaman `strings` ve `objdump -d` ile davranış çıkarımı daha zor ama
yine mümkün olurdu.

---

## 📌 Sonuç

Bu çalışmada **4 farklı platformda** (MSP430-Z1, MSP430-Sky, ARM-CC1352R,
x86-cooja-native) derlenmiş **16 firmware**, MSP430 ve ARM araç zincirleri kullanılarak
**23 başlık altında** analiz edilmiştir. Her başlıkta şablonun tüm alt maddeleri
**"Madde madde bulgular" tablosu** ile tek tek karşılanmış; her komut çıktısı salt
kopyalanmak yerine firmware'in rolü ve mimari anlamı açısından **"💡 Yorum"** paragrafında
yorumlanmıştır. Analizler, Part 1'de geliştirdiğimiz OTA firmware güncelleme sisteminin
(`own-*.z1`) yapısını da doğrulamış; gömülü bir firmware'in ELF yapısı, bellek yerleşimi,
kesme mekanizması ve ağ davranışının araç zinciriyle nasıl tamamen çözümlenebileceğini
göstermiştir.

*Ham analiz çıktıları `analysis-output/`, analiz betiği `run-analysis.sh`, incelenen
firmware'ler `firmware-samples/` klasöründedir.*
