#!/bin/bash


#################################################

cat > Analysis.C <<'DOC'

int Analysis(const char *readfile)
{

 TFile *rfile = new TFile(readfile,"update");

 TList *lofk = rfile->GetListOfKeys();

 TFile *wfile = new TFile("Analysis.root","update");
 if(!wfile){return 1;}

 TH1F *hist_p  = dynamic_cast<TH1F*>(wfile->Get("p"));
 if(!hist_p){hist_p = new TH1F("p", "proton traverse momentum", 500,0,7);}

 TH1F *hist_pi = dynamic_cast<TH1F*>(wfile->Get("pi"));
 if(!hist_pi){hist_pi = new TH1F("pi", "pion traverse momentum", 500,0,7);}

 TH1F *hist_k  = dynamic_cast<TH1F*>(wfile->Get("k"));
 if(!hist_k){hist_k = new TH1F("k", "kaon traverse momentum", 500,0,7);}



 for(Int_t i=0; i<lofk->GetEntries(); i++)
 {
  TTree *tree = (TTree*) rfile->Get(Form("%s;%d",lofk->At(i)->GetName(),i+1));

  if(!tree || strcmp(tree->ClassName(),"TTree"))
  {
   cout<<Form("%s is not TTree!",lofk->At(i)->GetName())<<endl; 
   continue;
  }

  Int_t pid = 0;
  Float_t px = 0., py = 0., pz = 0., E = 0.;
  tree->SetBranchAddress("PID",&pid);
  tree->SetBranchAddress("px",&px);
  tree->SetBranchAddress("py",&py);
  tree->SetBranchAddress("pz",&pz);
  tree->SetBranchAddress("E",&E);

  Int_t nParticles = (Int_t)tree->GetEntries();

  for(Int_t p = 0; p < nParticles; p++)
  {
   tree->GetEntry(p);
   Float_t pt = sqrt( pow(px,2) + pow(py,2) );
   
   if(abs(pid) == 2212)
	{
		hist_p->Fill(pt);
	}
 
   if(abs(pid) == 211 || abs(pid) == 111)
        {
                hist_pi->Fill(pt);
        }

   if(abs(pid) == 130 || abs(pid) == 310 || abs(pid) == 311 || abs(pid) == 321)
        {
                hist_k->Fill(pt);
        }

  }  

  }

 hist_p->Write(hist_p->GetName(),TObject::kSingleKey+TObject::kWriteDelete);
 hist_pi->Write(hist_pi->GetName(),TObject::kSingleKey+TObject::kWriteDelete);
 hist_k->Write(hist_k->GetName(),TObject::kSingleKey+TObject::kWriteDelete);

 wfile->Close(); 
 rfile->Close();

 return 0;
}
DOC

#################################################


cat > finalAnalysis.C <<'DOC'

int finalAnalysis()
{

 TFile *wfile = new TFile("Analysis.root","update");
 if(!wfile){return 1;}

 TH1F *hist_p  = dynamic_cast<TH1F*>(wfile->Get("p"));
 TH1F *hist_pi = dynamic_cast<TH1F*>(wfile->Get("pi"));
 TH1F *hist_k  = dynamic_cast<TH1F*>(wfile->Get("k"));

 TCanvas *c = new TCanvas("c","traverse momenta",2100,700);
 c->Divide(3,1);

 c->cd(1);
 hist_p->Draw();

 c->cd(2);
 hist_pi->Draw();

 c->cd(3);
 hist_k->Draw();

 // Save the canvas:
 c->SaveAs("traverse_momenta.pdf"); 
 c->SaveAs("traverse_momenta.eps"); 
 c->SaveAs("traverse_momenta.png"); 
 c->SaveAs("traverse_momenta.C");

 
 cout << endl << endl << "###############################################" << endl << endl;
 cout << "Average pt for the whole Dataset:" << endl;
 cout << "protons\t= " << hist_p->GetMean()  << " GeV/c" << endl;
 cout << "pions\t= "   << hist_pi->GetMean() << " GeV/c" << endl;
 cout << "kaons\t= "   << hist_k->GetMean()  << " GeV/c" << endl; 
 cout << endl << endl << "###############################################" << endl << endl;


 return 0;
}
DOC

#################################################



[[ ! -d $1 ]] && echo "Not a valid directory!" && return 2

for subDir in {0..9}; do

        [[ ! -d ${1}/${subDir} ]] && echo "ERROR: ${1}/${subDir} does not exist" && return 1

	root -l -b -q Analysis.C\(\"${1}/${subDir}/HIJING_LBF_test_small.root\"\) 1> /dev/null

done

root -l -b -q finalAnalysis.C

rm Analysis.C
rm finalAnalysis.C

return 0
