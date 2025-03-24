# authtest

A new Flutter project.
# authTest

Настройки консоли:
1 - отключил AppIntegrity в CloudConsole (но затем он включился обратно и настроился как нужно Fireabase, читать ниже)
2 - добавил apiKey в Firebase Console -> App Check -> Apps -> "..." -> Manage debug tokens (он прилетает в консоль при запуске прилы)
2* - но мне кажется можно было изначально не включать AppCheck, вроде бы это вообще отдельная штука, но до конца хз
3 - Добавил свои SHA1 SHA256, чтобы приложение не проваливало проверку
4 - проверяем https://console.cloud.google.com/apis/dashboard?inv=1&invt=Abs6qQ&project=dham-1111
 Включены: 
 - Firebase App Check API(раз уж включили в консоли), 
 - Google Play Integrity API(отключал, но я думаю что он включается именно при включении AppCheck в Firebase консоли),
 - Identity Toolkit API, 
 - Cloud Firestore API

Настройки в проекте:
1 - Настройка AppCheck
await FirebaseAppCheck.instance.activate(
androidProvider: AndroidProvider.debug,
appleProvider: AppleProvider.debug,
);
2 - Настройка FirebaseAuth
await FirebaseAuth.instance.setSettings(forceRecaptchaFlow: true);

Все прочее в проекте можно делать по-разному, сам функционал не должен от этого зависеть.

