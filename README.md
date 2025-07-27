# inception_of_things

<p1>Commandes vagrant pour gerer le projet</p1>
    - vagrant up            starts and provisions the vagrant environment
    - vagrant destroy -f    stops and deletes all traces of the vagrant machine

<p1>Module p1</p1>
Faire lancer le projet faire "vagrant up"

Pour nettoyer le projet faire "vagrant destroy -f"


<p1>Module p2</p1>

Pour ce module, il faut auparavant renseigner dans le fichier /etc/hosts les donnees suivantes :
    192.168.56.110 app1.com
    192.168.56.110 app2.com
    192.168.56.110 app3.com <-- Sachant que pour ce cas, il peut y avoir n'importe quelle URL car cette application est concidere comme le default backend

Pour lancer et nettoyer le projet, effectuez les memes commandes que pour le module p1.
