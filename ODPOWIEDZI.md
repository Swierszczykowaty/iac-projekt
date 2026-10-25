# Temat 5 — odpowiedzi do zadań wstępnych

> Przebieg w GitHub Codespaces (Ubuntu 24.04), OpenTofu 1.13.2, `hashicorp/random` 3.9.1.

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

1. Ile zasobów zaplanowano do utworzenia i jakie to zasoby?
   - …
2. Co pokazało `docker ps`? Czy kontener utworzony przez OpenTofu czymś się różni od utworzonego ręcznie w temacie 2?
   - …
3. Co napisało drugie `tofu apply`? Jak nazywa się ta właściwość narzędzia?
   - …
4. Jakie zasoby wymienia `tofu state list`?
   - …

## Zadanie 5.3. Dryf — ktoś „poprawił” coś ręcznie

1. Co wykrył `tofu plan` po ręcznym usunięciu kontenera? Jakim symbolem i jakim zdaniem to opisał?
   - …
2. Co to jest dryf konfiguracji i dlaczego w zespołach zakazuje się ręcznych zmian w infrastrukturze zarządzanej kodem?
   - …
3. Gdzie zapisany jest **stan pożądany**, a skąd narzędzie wie o **stanie rzeczywistym**?
   - …

## Zadanie 5.4. Zmienna, zmiana i sprzątanie

1. Co pokazał pierwszy `tofu plan` (bez zmiany portu) i dlaczego?
   - …
2. Co pokazał plan z portem 8082: zmiana „w miejscu” (`~`) czy zastąpienie (`-/+`)? Dlaczego, skoro zmieniła się tylko jedna liczba?
   - …
3. Ile zasobów usunął `tofu destroy`? Co pokazuje teraz `tofu state list`?
   - …
4. Jakie dwie zmienne (poza portem) warto by dodać, żeby ten sam kod obsłużył środowiska `dev` i `prod`?
   - …
