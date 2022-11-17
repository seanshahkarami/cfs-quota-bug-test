# CFS Quota Bug Test

At work, I noticed some throttling in some of our key data services we run in Kubernetes. Although I think the root cause was having too low of a cpu request set on those, I came to learn that there was a kernel level issue making this worse.

I first learned about it here: [CFS quotas can lead to unnecessary throttling](https://github.com/kubernetes/kubernetes/issues/67577)

I believe this was eventually patched in later kernel versions, but may still affect older systems.

I found a simple test case to check for this, thanks to Ivan Babrou.

This repo contains a Dockerized version of this very helpful post: [Overly aggressive CFS](https://gist.github.com/bobrik/2030ff040fad360327a5fab7a09c4ff1)

The high level summary here is, we run a test case which has a well defined work period of 5ms and _should not_ experience throttling.

If your kernel is affected by this problem, you'll see:
* When no cpu quotas are used, it runs as expected and the main work loop completes consistently in about 5ms.
* When cpu quotas are used, the main work loop randomly takes around 100ms to complete instead. (And I've seen it in occur in long bursts.)

That's something like a random 20x drop in performance for unclear reasons and this is for a pretty clean example. In more complicated, multiprocess applications like RabbitMQ, I'm not sure how bad this gets.

## Running with Docker

```sh
docker run --rm -it seanshahkarami/cfs-quota-bug-test -iterations 100 -sleep 100ms
docker run --rm -it seanshahkarami/cfs-quota-bug-test -iterations 100 -sleep 1000ms
docker run --rm -it --cpu-quota 20000 --cpu-period 100000 seanshahkarami/cfs-quota-bug-test -iterations 100 -sleep 100ms
docker run --rm -it --cpu-quota 20000 --cpu-period 100000 seanshahkarami/cfs-quota-bug-test -iterations 100 -sleep 1000ms
docker run --rm -it --cpu-quota 20000 --cpu-period 100000 seanshahkarami/cfs-quota-bug-test -iterations 10 -sleep 5000ms
```

## Running with Kubernetes

```sh
# test without quotas
kubectl apply -f job-without-quota.yaml

# test with quotas
kubectl apply -f job-with-quota.yaml
```
