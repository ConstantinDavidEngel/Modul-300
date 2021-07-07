# Dokumentation LB2:

### Idee

Meine Idee für die LB2 ist mit hilfe von 3 Raspis ein Kubernetes Cluster zu erstellen mit 1nem Master Node und 2 Worker Nodes. Für das Verwende ich 3 Raspi 4 Model B.

Die Idee ist es auf den 3 Raspis mit K3S ein Kubernetes Cluster aufzubauen auf dem ein Service deployment mit Nginx, Grafana und Prometheus lauft. Arbeiten werden gemacht in einem Ubuntu 20.04 mit Kubectl.

### Umsetzung
Als erstes müssen wir die 3 Raspis Container ready machen dafür müssen wir in der Shell in der /boot/cmdline datei 2 parameter setzten und dann die Raspis neustarten. Das machen wir damit man auf den Raspis eine Container Umgebung laufen lassen kann. Würde man das nicht machen würde das installieren von K3S schief gehen und man könnte nicht weitermachen.

```bash
cgroup_memory=1 cgroup_enable=memory
init 6
```

Als erstes installieren wir K3S auf dem Master Node und überprüfen ob sich der Service installiert hat. Installieren machen wir das mit dem Curl command welcher das K3S Package Downloaded und das Script ausführt welches heruntergeladen wird.
Mit dem Systemctl Command wird mit dem Parameter Status überprüft was der Status von dem Service ist den man auswählt. In unserem Fall ist das K3S, wenn der Output zeigt, dass K3S läuft hat die Installation funktioniert.

```bash
curl -sfL https://get.k3s.io | sh -
systemctl status k3s
```

Wenn sich alles installiert hat kann man weiter machen indem man überprüft ob das K3S richtig funktioniert und ob die Umgebung auch der Master Cluster ist. Der Befehl kubectl ist die Command line für K3S welches wir vorher installiert haben. Mit dem Parameter get können wir daten abrufen, welche von einem weiteren Parameter definiert werden. In diesem Fall verwenden wir den Parameter nodes, welcher die Server (Raspis) anzeigt, welche im Cluster sind. Weil wir die weiteren Raspis noch nicht hinzugefügt haben, wird es uns nur 1 Node anzeigen.

```bash
kubectl get nodes

NAME        STATUS   ROLES    AGE     VERSION
k3smaster   Ready    master   11m     v1.21.2+k3s1
```

Wenn die Ausgabe normal ist, muss man mit den 2 weiteren Raspis die Worker Nodes aufsetzten. Dafür nehmen wir den Node URL aus dem Master und setzten das in eine Variable auf den Worker Nodes hinterlegt.

```
export K3S_URL="https://192.168.0.100:6443"
curl -sfL https://get.k3s.io | sh -
```

Wir haben jetzt auf beiden Worker Nodes K3S installiert und das sollte sich von alleine mit dem Master verbinden, weil wir die Node URL des Masters weiter an die Worker gegeben haben. Um das zu überprüfen führen wir wie vorher den gleichen überprüfungs Befehl aus und wenn das funktioniert hat, sollten dort auch die 2 Worker Nodes angezeigt werden.

```
kubectl get nodes

NAME        STATUS   ROLES    AGE     VERSION
k3smaster   Ready    master   42m     v1.21.2+k3s1
k3snode1    Ready    worker   15m     v1.21.2+k3s1
k3snode2    Ready    worker   4m32s   v1.21.2+k3s1
```

Wir haben jetzt die 3 Raspis verbunden und sie laufen jetzt machen wir weiter indem wir einen Namespace “school” installieren zusätzlich zu einem Nginx. Das machen wir mit Helm Charts.

helm install nginx-ingress stable/nginx-ingress --namespace school
Um das Nginx jetzt mit einem Dashboard zu überwachen benutzen wir Grafana mit Prometheus, da wir ein Kubernetes Deployment haben wäre es unnötig das alles manuell zu konfigurieren und benutzen ein Git Repo mit einem Make file, welches das Deployment für die Konfiguration automatisiert.

```bash
git clone https://github.com/carlosedp/cluster-monitoring.git
make deploy
```

Damit haben sich jetzt ein Prometheus und ein Grafana Pod mit einem Node exporter erstellt, welche auf das Nginx zugreifen und damit kann man das Nginx monitorn. Dazu sind alle Pods die in dieser Doku erstellt worden sind mit 3 Replicas am laufen damit wenn einer ausfällt 2 weitere laufen und ein neuer erstellt werden würde.
