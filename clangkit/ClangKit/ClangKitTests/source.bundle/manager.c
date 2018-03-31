//
//  QICryptManager.c
//  DiffieHellman
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2014 Volodymyr Pavliukevych. All rights reserved.
//

#include "QICryptManager.h"

// Helper
void print_hex(BYTE str[], int len, QI_Crypt_Print_Type type) {
	int idx;
	
	for(idx = 0; idx < len; idx++) {
	
		switch (type) {
			case QI_Crypt_Print_Type_HEX:
				printf("%02x", str[idx]);
				break;
			case QI_Crypt_Print_Type_HEX_Spaced:
				printf("0x%02x ", str[idx]);
				break;
			case QI_Crypt_Print_Type_Value:
				printf("%i	", str[idx]);
				break;
				
			default:
				break;
		}
	}
}



// Diffie Hellman
short int isPrime(unsigned long int n){
	long int i;
	if (n % 2 == 0) {
		return 0;
	}
	for (i = 3; i < ceil(sqrt(n)); i+=2){
		if(n % i == 0) {
			return 0;
		}
	}
	return 1;
}



unsigned long int randomPrime(){
	unsigned long int r;
	while(1){
		r = rand() % UINT8_MAX;
		if(isPrime(r))
			return r;
	}
}



unsigned long int quickExponentiation(unsigned long int a, unsigned long int b, unsigned long int n) {
	unsigned long int res = 1, pot = a % n;
	while(b){
		if(b % 2 == 1){
			res = (pot * res) % n;
		}
		pot = (pot * pot) % n;
		b = b >> 1;
	}
	return res;
}


// Crypt manager
void init_peripheral_manager(unsigned long int p_key[32], unsigned long int g_key[32], QI_Crypt_Manager_t *crypt_manager) {
	
	for (int index = 0; index < 32; index++) {
		
		unsigned long int g = g_key[index];
		unsigned long int x = rand() % p_key[index] + 1;
		unsigned long int fx = quickExponentiation(g, x, p_key[index]);

		crypt_manager->g_key[index] = g;
		crypt_manager->x_key[index] = x;
		crypt_manager->public_key[index] = fx;
		crypt_manager->p_key[index] = p_key[index];
		
	}
	

}


void init_central_manager(unsigned long int p_key[32], unsigned long int g_key[32], QI_Crypt_Manager_t *crypt_manager) {
	
	for (int index = 0; index < 32; index++) {
		
		unsigned long int g = g_key[index];
		unsigned long int x = ((rand() % p_key[index]) * (rand() % p_key[index]) % p_key[index]) + 1;
		unsigned long int fx = quickExponentiation(g, x, p_key[index]);

		crypt_manager->g_key[index] = g;
		crypt_manager->x_key[index] = x;
		crypt_manager->public_key[index] = fx;
		crypt_manager->p_key[index] = p_key[index];

	}
}


void create_private_key(unsigned long int client_public_key[32], QI_Crypt_Manager_t *crypt_manager){
	for (int index = 0; index < 32; index++) {
		unsigned long int x  = crypt_manager->x_key[index];
		unsigned long int p  = crypt_manager->p_key[index];
		unsigned long int private_key = quickExponentiation(client_public_key[index], x, p);
		crypt_manager->private_key[index] = private_key;
	}
	
}


QI_Crypt_Manager_Init_Value_t init_p_g_value() {

	QI_Crypt_Manager_Init_Value_t value;
	
	for (int i = 0; i < 32; i++) {
		value.p_key[i] = randomPrime();
		value.g_key[i] = rand() % value.p_key[i] - 1;
	}
	
	return value;

}
