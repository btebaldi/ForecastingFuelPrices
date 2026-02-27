#include <oxstd.oxh>
#include "./my_help.ox"

main()
{
	// Arquivo de configuracao
	#include "./Config.ini"
	
	println("Script responsavel pelo 'stacking' das variaveis \n");
	println("GVAR Passo 3 Inicializado");
	decl sVarSufix;
	sVarSufix = "D_";

	decl mWi, mAi_l, GL, mUi, mUStack, mAlphai, aAlphaiStack, mIISi, mIISiStack, mDi, mDStack,  iContRegion, iCurrentLag, mBetai;

	for(iCurrentLag = 0; iCurrentLag <= iQtdLags; ++iCurrentLag)
	{
	
		for(iContRegion=1; iContRegion<=iQtdRegioes; ++iContRegion)
	    {
			// Carrega a matriz de pesso da regiao.
			mWi = loadmat(sprint(txMatPathW_Matrix, "W", iContRegion,".mat"));
			
			// Carrega a Matriz de coeficientes
			mAi_l = loadmat(sprint(txMatPathA_Matrix, "A", iContRegion, "_", iCurrentLag, ".mat"));
			
			// primeira passagem, inicializo o G0 e GL
			if(iContRegion==1)
			{
				GL =  mAi_l * mWi;
			}
			else
			{
				GL = GL | (mAi_l * mWi);
			}
			//println(GL);
	    }
		//println("Saving G", iCurrentLag, " matrix");
		savemat(sprint(txMatPathG_Matrix, "G", iCurrentLag, ".mat"), GL);
	}

	// PROCESSO DE CONSTRUCAO DA MATRIZ DE CONSTANTES E SEASONAL
	println("Realizando processo de stacking das matrizes U (Cosntantes e Seasons)");
	for(iContRegion=1; iContRegion<=iQtdRegioes; ++iContRegion)
	{
		mUi = loadmat(sprint(txMatPathRawMatrix, sVarSufix, "R", iContRegion, "_U.mat"));

		// primeira passagem, inicializo o U0 e UL
		if(iContRegion==1)
		{
			mUStack =  mUi;
		}
		else
		{
			mUStack = mUStack | mUi;
		}

		//println("Saving U_Stacked (region ", iContRegion, ")");
		savemat(sprint(txMatPathG_Matrix, "U_Stacked", ".mat"), mUStack);
	}


	// PROCESSO DE CONSTRUCAO DA MATRIZ ALPHA
	println("Realizando processo de stacking das matrizes Alpha");
	decl mPerp = (zeros(2, 2*columns(aVarDependenteNames)) ~ unit(2)) | (unit(2*columns(aVarDependenteNames)) ~ zeros(2*columns(aVarDependenteNames), 2));

	//println("mPerp=", mPerp');
	for(iContRegion=1; iContRegion<=iQtdRegioes; ++iContRegion)
	{
		mAlphai = loadmat(sprint(txMatPathRawMatrix, sVarSufix, "R", iContRegion, "_Alpha.mat"));
		mBetai = loadmat(sprint(txCoIntMatPath, "Weak2_CoInt_R", iContRegion, ".mat"));
		mWi = loadmat(sprint(txMatPathW_Matrix, "W", iContRegion, ".mat"));

		
        //println("Regularizacao do beta para operacionalizacao");
		
		// Regularizacao do beta para operacionalizacao.
		if(columns(mAlphai) > rows(mBetai))
		{
		//adiciono uma linha zerada no beta pois nao há dois betas.
		mBetai = mBetai | reshape(0, columns(mAlphai) - rows(mBetai), columns(mBetai));;
		}

//		println(rows(mAlphai),"x",columns(mAlphai), "*", rows(mBetai), "x",columns(mBetai));
//		println("%r", {"ETA", "DIS", "GAS"}, "%c", {"ETA", "DIS", "GAS"}, mAlphai);
//		println("%r", {"ETA", "DIS", "GAS"}, "%c", {"ETA", "DIS", "GAS", "ETA*", "DIS*", "GAS*", "brent", "FX"}, mBetai);
//
		// Realiza a permutacao das colunas para deixar brent e FX na primeira coluna
		mBetai = mBetai * mPerp';
//		println("\nNEW BETA",  "%r", {"ETA", "DIS", "GAS"}, "%c", {"ETA", "DIS", "GAS", "ETA*", "DIS*", "GAS*", "brent", "FX"}, mBetai);
//	
//		
//		//println("primeira passagem, inicializo o Aplha0 e AplhaL");
//		println("%r", {"ETA", "DIS", "GAS"}, "%c", {"ETA", "DIS", "GAS", "ETA*", "DIS*", "GAS*", "brent", "FX"}, mAlphai * mBetai);
//		println("mWi = ", mWi);

//		dim(mWi);

		// mWi_star sera a matriz combinada com a Identidade, para garantir que os vetores de cointegracao serao corretamente multiplicados 
		decl mWi_star = diagcat(unit(2), mWi);
//		dim(mWi_star);
//		println("mWi_star = ", mWi_star);
		
		// primeira passagem, inicializo o Aplha0 e AplhaL
		if(iContRegion==1)
		{
//			aAlphaiStack =  mAlphai * mBetai * mWi;
			aAlphaiStack =  mAlphai * mBetai * mWi_star;
		}
		else
		{
			//aAlphaiStack = (aAlphaiStack ~ zeros(rows(aAlphaiStack), columns(mAlphai))) | (zeros(rows(mAlphai), columns(aAlphaiStack)) ~ mAlphai);
			//aAlphaiStack = aAlphaiStack | mAlphai * mBetai * mWi;
//			println("aAlphaiStack = ", aAlphaiStack);
//			println("mAlphai = ", mAlphai);
//			println("mBetai = ", mBetai);
//			println("mWi_star = ", mWi_star);
			aAlphaiStack = aAlphaiStack | mAlphai * mBetai * mWi_star;
		}

		//println(sprint("Saving G_alpha (region ",iContRegion, ")"));
		//savemat(sprint(txMatPathG_Matrix, "G_alpha", ".mat"), aAlphaiStack);
		savemat(sprint(txMatPathG_Matrix, "G_alpha_v2", ".mat"), -aAlphaiStack);
	}

	//exit(1);

	// PROCESSO DE CONSTRUCAO DA MATRIZ IIS
	println("Realizando processo de stacking das matrizes IIS");
	for(iContRegion=1; iContRegion<=iQtdRegioes; ++iContRegion)
	{
		mIISi = loadmat(sprint(txMatPathRawMatrix, sVarSufix, "R", iContRegion, "_IIS.mat"));

		// primeira passagem, inicializo o IIS0 e IISL
		if(iContRegion==1)
		{
			mIISiStack =  mIISi;
		}
		else
		{
			mIISiStack = mIISiStack | mIISi;
		}

		//println(sprint("Saving IIS (region ",iContRegion, ")"));
		savemat(sprint(txMatPathG_Matrix, "IIS_Stacked", ".mat"), mIISiStack);
	}

	// PROCESSO DE CONSTRUCAO DA MATRIZ D
	println("Realizando processo de stacking da matrizes D");
	for(iContRegion=1; iContRegion<=iQtdRegioes; ++iContRegion)
	{
		mDi = loadmat(sprint(txMatPathRawMatrix, sVarSufix, "R", iContRegion, "_D.mat"));

		// primeira passagem, inicializo o D0 e DL
		if(iContRegion==1)
		{
			mDStack =  mDi;
		}
		else
		{
			mDStack = mDStack | mDi;
		}

		//println(sprint("Saving D_Stacked (region ",iContRegion, ")"));
		savemat(sprint(txMatPathG_Matrix, "D_Stacked", ".mat"), mDStack);
	}

	println("Processo finalizado.");
}
