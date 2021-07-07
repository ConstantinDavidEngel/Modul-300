# Dokumentation LB2:

Idee:

Meine Idee für die LB2 ist mit hilfe von 3 Raspis ein Kubernetes Cluster zu erstellen mit 1nem Master Node und 2 Worker Nodes. Für das Verwende ich 3 Raspi 4 Model B.

Neue Idee:

Die Idee ist es auf den 3 Raspis mit K3S ein Kubernetes Cluster aufzubauen auf dem ein Service deployment mit Nginx, Grafana und Prometheus lauft. Arbeiten werden gemacht in einem Ubuntu 20.04 mit Kubectl.

Umsetzung
Als erstes müssen wir die 3 Raspis Container ready machen dafür müssen wir in der Shell in der /boot/cmdline datei 2 parameter setzten und dann die Raspis neustarten.

cgroup_memory=1 cgroup_enable=memory
init 6
Als erstes installieren wir K3S auf dem Master Node und überprüfen ob sich der Service installiert hat.

curl -sfL https://get.k3s.io | sh -
systemctl status k3s
Wenn sich alles installiert hat kann man weiter machen indem man überprüft ob das K3S richtig funktioniert und ob die Umgebung auch der Master Cluster ist.

kubectl get nodes
Wenn die Ausgabe normal ist, muss man mit den 2 weiteren Raspis die Worker Nodes aufsetzten. Dafür nehmen wir den Node URL aus dem Master und setzten das in eine Variable auf den Worker Nodes hinterlegt.

export K3S_URL="https://192.168.0.100:6443"
curl -sfL https://get.k3s.io | sh -
Wir haben jetzt auf beiden Worker Nodes K3S installiert und das sollte sich von alleine mit dem Master verbinden, weil wir die Node URL des Masters weiter an die Worker gegeben haben. Um das zu überprüfen führen wir wie vorher den gleichen überprüfungs Befehl aus und wenn das funktioniert hat, sollten dort auch die 2 Worker Nodes angezeigt werden.

kubectl get nodes

NAME        STATUS   ROLES    AGE     VERSION
k3smaster   Ready    master   42m     v1.21.2+k3s1
k3snode1    Ready    worker   15m     v1.21.2+k3s1
k3snode2    Ready    worker   4m32s   v1.21.2+k3s1
Wir haben jetzt die 3 Raspis verbunden und sie laufen jetzt machen wir weiter indem wir einen Namespace “school” installieren zusätzlich zu einem Nginx. Das machen wir mit Helm Charts.

helm install nginx-ingress stable/nginx-ingress --namespace school
Um das Nginx jetzt mit einem Dashboard zu überwachen benutzen wir Grafana mit Prometheus, da wir ein Kubernetes Deployment haben wäre es unnötig das alles manuell zu konfigurieren und benutzen ein Git Repo mit einem Make file, welches das Deployment für die Konfiguration automatisiert.

git clone https://github.com/carlosedp/cluster-monitoring.git
make deploy
Damit haben sich jetzt ein Prometheus und ein Grafana Pod mit einem Node exporter erstellt, welche auf das Nginx zugreifen und damit kann man das Nginx monitorn. Dazu sind alle Pods die in dieser Doku erstellt worden sind mit 3 Replicas am laufen damit wenn einer ausfällt 2 weitere laufen und ein neuer erstellt werden würde.
