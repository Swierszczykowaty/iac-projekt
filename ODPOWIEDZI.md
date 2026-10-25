# Temat 5 — odpowiedzi do zadań wstępnych

> Przebieg w GitHub Codespaces (Ubuntu 24.04), OpenTofu 1.13.2, `hashicorp/random` 3.9.1, `kreuzwerker/docker` 3.9.0.

## Zadanie 5.1. Instalacja i pierwszy „zasób”

1. **Jaką nazwę wylosowało OpenTofu? Czy przy drugim `apply` nazwa się zmieniła? Co narzędzie napisało i dlaczego?**
   - Wylosowana nazwa: **`closing-sawfly`**.
   - Przy drugim `apply` nazwa się **nie zmieniła**. OpenTofu odświeżyło stan (`random_pet.nazwa: Refreshing state... [id=closing-sawfly]`) i napisało: `No changes. Your infrastructure matches the configuration.` oraz `Apply complete! Resources: 0 added, 0 changed, 0 destroyed.`
   - Powód: zasób jest już zapisany w pliku stanu, a konfiguracja się nie zmieniła — stan pożądany (kod) i zapisany są zgodne, więc nie ma czego zmieniać. Nazwa jest losowana tylko raz, przy tworzeniu zasobu (idempotentność).

2. **Co oznacza znak `+` w wyniku `tofu plan` i ile zasobów miało zostać dodanych?**
   - `+` oznacza **utworzenie** zasobu (`+ create`).
   - Do dodania był **1 zasób** — `random_pet.nazwa` (`Plan: 1 to add, 0 to change, 0 to destroy.`); output `nazwa_projektu` miał wartość `(known after apply)`.

3. **Jakie nowe pliki i katalogi pojawiły się po `tofu init` i `tofu apply` (`ls -a`)?**
   - `ls -a`: `.terraform/`, `.terraform.lock.hcl`, `main.tf`, `terraform.tfstate`.
   - Po `tofu init`: katalog **`.terraform/`** (pobrany provider `hashicorp/random` v3.9.1) i plik **`.terraform.lock.hcl`** (przypięta wersja i sumy kontrolne providera — ten plik commituje się do repozytorium).
   - Po `tofu apply`: plik stanu **`terraform.tfstate`**.

4. **Co jest zapisane w pliku `terraform.tfstate`? Dlaczego w prawdziwych projektach nie umieszcza się go w publicznym repozytorium?**
   - To plik JSON zawierający m.in.: `version` (wersja formatu, `4`), `terraform_version` (`1.13.2`), `serial` (numer kolejnej wersji stanu, `1`), `lineage` (unikalny identyfikator stanu), `outputs` (`nazwa_projektu = "closing-sawfly"`) oraz `resources` — typ (`random_pet`), nazwę (`nazwa`), providera (`registry.opentofu.org/hashicorp/random`) i **wszystkie atrybuty** zasobu (`id`, `length = 2`, `prefix`, `keepers`…).
   - Nie umieszcza się go w publicznym repozytorium, bo stan przechowuje atrybuty zasobów **jawnym tekstem** — w prawdziwych projektach także hasła do baz, klucze i tokeny — oraz szczegóły infrastruktury przydatne atakującemu. Przy pracy zespołowej lokalne kopie stanu by się też rozjeżdżały; w praktyce stan trzyma się w zdalnym backendzie z blokadą (np. S3 + DynamoDB).

## Zadanie 5.2. Kontener opisany kodem

1. **Ile zasobów zaplanowano do utworzenia i jakie to zasoby?**
   - **2 zasoby** (`Plan: 2 to add, 0 to change, 0 to destroy.`):
     - `docker_image.nginx` — pobranie obrazu `nginx:alpine`,
     - `docker_container.web` — kontener `web-iac` z mapowaniem portu `8081 → 80` (`ip = "0.0.0.0"`, `protocol = "tcp"`).
   - Dodatkowo output `adres = "http://localhost:8081"`.

2. **Co pokazało `docker ps`? Czy kontener utworzony przez OpenTofu czymś się różni od utworzonego ręcznie w temacie 2?**
   - `docker ps` pokazało działający kontener **`web-iac`** (ID `110dd744ebcf`, obraz `a3554c0d0b48`, polecenie `/docker-entrypoint.…`, status `Up`, porty `0.0.0.0:8081->80/tcp`). `curl -s localhost:8081` zwrócił `<title>Welcome to nginx!</title>`.
   - Sam kontener **niczym się nie różni** od uruchomionego ręcznie przez `docker run` — Docker nie wie, kto go utworzył. Różnica jest w sposobie zarządzania: konfiguracja jest zapisana w kodzie (powtarzalna, w repozytorium, z historią zmian), a OpenTofu zapamiętuje kontener w stanie, więc wykrywa zmiany, potrafi go odtworzyć lub usunąć jednym poleceniem.

3. **Co napisało drugie `tofu apply`? Jak nazywa się ta właściwość narzędzia?**
   - Odświeżyło stan obu zasobów (`Refreshing state...`) i napisało: `No changes. Your infrastructure matches the configuration.` oraz `Apply complete! Resources: 0 added, 0 changed, 0 destroyed.`
   - Ta właściwość to **idempotentność** — wielokrotne wykonanie tej samej konfiguracji daje ten sam wynik i nie tworzy duplikatów.

4. **Jakie zasoby wymienia `tofu state list`?**
   - `docker_container.web`
   - `docker_image.nginx`

## Zadanie 5.3. Dryf — ktoś „poprawił” coś ręcznie

1. **Co wykrył `tofu plan` po ręcznym usunięciu kontenera? Jakim symbolem i jakim zdaniem to opisał?**
   - Po `docker rm -f web-iac` (pusty `docker ps`) `tofu plan` odświeżył stan (`docker_container.web: Refreshing state... [id=c96ccb9477f6…]`), wykrył, że kontenera zapisanego w stanie już nie ma, i zaplanował jego ponowne utworzenie symbolem **`+`**: `# docker_container.web will be created` oraz `Plan: 1 to add, 0 to change, 0 to destroy.`
   - Obraz `docker_image.nginx` nadal istniał, więc nie był ruszany — w planie widać od razu jego konkretny identyfikator (`image = "sha256:a3554c0d…"`).
   - Po `tofu apply` (`Resources: 1 added, 0 changed, 0 destroyed.`) kontener `web-iac` znów działa, z nowym ID `908dda6467a0` i portami `0.0.0.0:8081->80/tcp` — dryf został naprawiony.

2. **Co to jest dryf konfiguracji i dlaczego w zespołach zakazuje się ręcznych zmian w infrastrukturze zarządzanej kodem?**
   - **Dryf** (*drift*) to rozjazd między stanem opisanym w kodzie / zapisanym w stanie a rzeczywistą infrastrukturą, najczęściej po ręcznej zmianie „na boku”.
   - Ręczne zmiany są zakazane, bo: nie ma ich w historii repozytorium (brak audytu „kto, kiedy, dlaczego” i przeglądu przed wdrożeniem), następny `apply` je nadpisze lub cofnie, środowiska `dev` i `prod` przestają być identyczne, a odtworzenie po awarii z kodu da inną infrastrukturę niż ta, która faktycznie działała.

3. **Gdzie zapisany jest stan pożądany, a skąd narzędzie wie o stanie rzeczywistym?**
   - **Stan pożądany** — w plikach konfiguracji `*.tf` (z wartościami zmiennych). Ostatni znany stan utworzonych zasobów jest zapisany w `terraform.tfstate`.
   - **Stan rzeczywisty** — OpenTofu odpytuje platformę przez providera (tu: API Dockera) w fazie odświeżania (`Refreshing state...`) przy `plan`/`apply` i porównuje wynik ze stanem zapisanym oraz z kodem.

## Zadanie 5.4. Zmienna, zmiana i sprzątanie

1. **Co pokazał pierwszy `tofu plan` (bez zmiany portu) i dlaczego?**
   - `No changes. Your infrastructure matches the configuration.`
   - Zmienna `port_zewnetrzny` ma wartość domyślną **`8081`**, czyli dokładnie tę, która wcześniej była wpisana na sztywno. Zmienił się tylko sposób zapisu w kodzie (stała → zmienna), a nie wynikowa konfiguracja, więc nie ma różnicy względem działającej infrastruktury.

2. **Co pokazał plan z portem 8082: zmiana „w miejscu” (`~`) czy zastąpienie (`-/+`)? Dlaczego, skoro zmieniła się tylko jedna liczba?**
   - **Zastąpienie `-/+`** (`-/+ destroy and then create replacement`): `# docker_container.web must be replaced`, przy porcie `~ external = 8081 -> 8082 # forces replacement`, `Plan: 1 to add, 0 to change, 1 to destroy.`, a output zmienia się na `adres = "http://localhost:8082"`.
   - Docker **nie pozwala zmienić mapowania portów istniejącego kontenera** — port ustala się przy jego tworzeniu. Provider oznacza więc ten atrybut jako wymuszający zastąpienie: stary kontener (`a18d5c5f84bf`) został usunięty i utworzony nowy (`250e11465aa1`), mimo że zmieniła się tylko jedna liczba. Obraz `nginx` nie był ruszany. `curl -s localhost:8082` zwrócił `<title>Welcome to nginx!</title>`.

3. **Ile zasobów usunął `tofu destroy`? Co pokazuje teraz `tofu state list`?**
   - **2 zasoby**: `docker_container.web` i `docker_image.nginx` (`Plan: 0 to add, 0 to change, 2 to destroy.` → `Destroy complete! Resources: 2 destroyed.`), a output `adres` został usunięty.
   - `tofu state list` **nie zwraca nic** — stan jest pusty. `docker ps` również nie pokazuje żadnego kontenera.

4. **Jakie dwie zmienne (poza portem) warto by dodać, żeby ten sam kod obsłużył środowiska `dev` i `prod`?**
   - **`srodowisko`** (`dev` / `prod`) — przedrostek nazw zasobów, np. `name = "${var.srodowisko}-web"`, żeby oba środowiska mogły działać obok siebie bez kolizji nazw.
   - **`liczba_kopii`** — liczba kontenerów aplikacji (`count = var.liczba_kopii`), np. 1 w `dev` i 3 w `prod`.
   - (alternatywnie **`wersja_obrazu`** — tag obrazu, np. przypięta wersja w `prod` zamiast ruchomego `alpine`).