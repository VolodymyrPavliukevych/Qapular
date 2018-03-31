//
//  QICryptManager.h
//  DiffieHellman
//
//  Created by Volodymyr Pavliukevych.
//  Copyright (c) 2014 Volodymyr Pavliukevych. All rights reserved.
//

#ifndef __DiffieHellman__QICryptManager__
#define __DiffieHellman__QICryptManager__

#include <stdio.h>


typedef struct QI_Crypt_Manager {
	
	unsigned long int p_key[32];			/*P value*/
	unsigned long int g_key[32];			/*G value*/
	unsigned long int x_key[32];			/*X value*/
	unsigned long int public_key[32];
	unsigned char private_key[32];
	
} QI_Crypt_Manager_t;

typedef unsigned char BYTE;            // 8-bit byte


typedef enum {
	QI_Crypt_Print_Type_HEX,
	QI_Crypt_Print_Type_HEX_Spaced,
	QI_Crypt_Print_Type_Value
} QI_Crypt_Print_Type;


typedef struct QI_Crypt_Manager_Init_Value {

	unsigned long int p_key[32];
	unsigned long int g_key[32];

} QI_Crypt_Manager_Init_Value_t;


QI_Crypt_Manager_Init_Value_t init_p_g_value();
void create_private_key(unsigned long int  client_public_key[32], QI_Crypt_Manager_t *crypt_manager);
void init_central_manager(unsigned long int p_key[32], unsigned long int g_key[32], QI_Crypt_Manager_t *crypt_manager);
void init_peripheral_manager(unsigned long int p_key[32], unsigned long int g_key[32], QI_Crypt_Manager_t *crypt_manager);

void print_hex(BYTE str[], int len, QI_Crypt_Print_Type type);

#endif /* defined(__DiffieHellman__QICryptManager__) */
