//
//  KCPreviewViewController.swift
//  Invoice
//
//  Created by Kevin Choi on 1/13/19.
//  Copyright © 2019 Kevin Choi. All rights reserved.
//

import UIKit

class KCPreviewViewController: UIViewController {
    
    @IBOutlet weak var webPreview: UIWebView!
    @IBOutlet weak var printButton: UIBarButtonItem!
    
    var invoiceInfo: [String: AnyObject]!
    
    var invoiceComposer: InvoiceComposer!
    
    var HTMLContent: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createInvoiceAsHTML()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: IBAction Methods
    
    
    @IBAction func exportToPDF(_ sender: AnyObject) {
        //let pdfData = invoiceComposer.exportHTMLContentToPDF(HTMLContent: HTMLContent)
        let pdfData = invoiceComposer.exportWebViewToPDF(printFormatter: webPreview.viewPrintFormatter())
        
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = "invoice"
        
        // Set up print controller
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        
        // Assign a UIImage version of my UIView as a printing iten
        printController.printingItem = pdfData
        
        // Do it
        printController.present(from:self.printButton, animated: true, completionHandler: nil)
        
        //showOptionsAlert()
    }
    
    
    // MARK: Custom Methods
    
    func createInvoiceAsHTML() {
        invoiceComposer = InvoiceComposer()
        if let invoiceHTML = invoiceComposer.renderInvoice(invoiceNumber: invoiceInfo["invoiceNumber"] as! String,
                                                           invoiceDate: invoiceInfo["invoiceDate"] as! String,
                                                           senderInfo: invoiceInfo["senderInfo"] as! String,
                                                           recipientInfo: invoiceInfo["recipientInfo"] as! String,
                                                           items: invoiceInfo["items"] as! [[String: String]],
                                                           discount: invoiceInfo["discount"] as! String,
                                                           totalAmount: invoiceInfo["totalAmount"] as! String,
                                                           currency: invoiceInfo["currency"] as! String,
                                                           paymentMethod: invoiceInfo["paymentMethod"] as! String) {
            
            webPreview.loadHTMLString(invoiceHTML, baseURL: NSURL(string: invoiceComposer.pathToInvoiceHTMLTemplate!)! as URL)
            HTMLContent = invoiceHTML
        }
    }
    
    
    /*
    func showOptionsAlert() {
        let alertController = UIAlertController(title: "Yeah!", message: "Your invoice has been successfully printed to a PDF file.\n\nWhat do you want to do now?", preferredStyle: UIAlertControllerStyle.alert)
        
        let actionPreview = UIAlertAction(title: "Preview it", style: UIAlertActionStyle.default) { (action) in
            if let filename = self.invoiceComposer.pdfFilename, let url = URL(string: filename) {
                let request = URLRequest(url: url)
                self.webPreview.loadRequest(request)
            }
        }
        
        let actionEmail = UIAlertAction(title: "Send by Email", style: UIAlertActionStyle.default) { (action) in
            DispatchQueue.main.async {
                self.sendEmail()
            }
        }
        
        let actionNothing = UIAlertAction(title: "Nothing", style: UIAlertActionStyle.default) { (action) in
            
        }
        
        alertController.addAction(actionPreview)
        alertController.addAction(actionEmail)
        alertController.addAction(actionNothing)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.setSubject("Invoice")
            mailComposeViewController.addAttachmentData(NSData(contentsOfFile: invoiceComposer.pdfFilename)! as Data, mimeType: "application/pdf", fileName: "Invoice")
            present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    */
}
