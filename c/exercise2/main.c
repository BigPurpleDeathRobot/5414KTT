// gcc 4.7.2 +
// gcc -std=gnu99 -Wall -g -o helloworld_c helloworld_c.c -lpthread

#include <pthread.h>
#include <stdio.h>

int i=0;
pthread_mutex_t mutex1 = PTHREAD_MUTEX_INITIALIZER;
//pthread_mutex_t mutex2 = PTHREAD_MUTEX_INITIALIZER;


// Note the return type: void*
void* thread1Function()
{
    int j;
    for (j=0; j<1000000; j++){
    	pthread_mutex_lock(&mutex1);
    	    	i++;
    	pthread_mutex_unlock(&mutex1);
    }

    return NULL;
}

void* thread2Function()
{
    int j;
    for (j=0; j<1000000; j++){
    pthread_mutex_lock(&mutex1);
    	i--;
    pthread_mutex_unlock(&mutex1);
    }

    return NULL;
}



int main()
{
    pthread_t thread[2];

    int pthreadCreateReturn;
    if(pthreadCreateReturn = pthread_create(&thread[0], NULL, thread1Function, NULL))
    {
    	printf("thread1 fail, error:%d\n", pthreadCreateReturn);
    }
    if(pthreadCreateReturn = pthread_create(&thread[1], NULL, thread2Function, NULL))
    {
    	printf("thread2 fail, error:%d\n", pthreadCreateReturn);
    }

    pthread_join(thread[0], NULL);
    pthread_join(thread[1], NULL);

    printf("%d\n",i);

    return 0;
}
