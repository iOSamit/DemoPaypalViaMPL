//
//  DPPaypalVC.swift
//  DemoPaypalViaMPL
//
//  Created by Amit on 07/07/2015 SAKA.
//  Copyright © 2016 Dream World. All rights reserved.
//

import UIKit
enum PaymentStatuses {
    case PAYMENTSTATUS_SUCCESS,
    PAYMENTSTATUS_FAILED,
    PAYMENTSTATUS_CANCELED
}
class DPPaypalVC: UIViewController ,UITextFieldDelegate {
    
    var y:CGFloat  = 20.0
    let spacing:CGFloat  = 3.0
    var preapprovalField:UITextField = UITextField()
    var status:PaymentStatuses = PaymentStatuses.PAYMENTSTATUS_CANCELED
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLabelWithText("Simple Payment", type:BUTTON_294x43, action: #selector(DPPaypalVC.simplePayment))
        addLabelWithText("Parallel Payment", type:BUTTON_294x43, action: #selector(DPPaypalVC.parallelPayment))
        addLabelWithText("Chained Payment", type:BUTTON_294x43, action: #selector(DPPaypalVC.chainedPayment))
        addLabelWithText("Preapproval", type:BUTTON_294x43, action: #selector(DPPaypalVC.Preapproval))
        
        preapprovalField  = addTextFieldWithPlaceholder("Preapproval Key")
        addAppInfoLabel()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func addLabelWithText(text:NSString,type:PayPalButtonType,action:Selector){
        let size: CGSize = text.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14.0)])
        let button  = PayPal.getPayPalInst().getPayButtonWithTarget(self, andAction: action, andButtonType: type)
        var frame = button.frame
        frame.origin.x = round((self.view.frame.size.width -  button.frame.size.width) / 2)
        frame.origin.y = round(y + size.height)
        button.frame = frame
        self.view .addSubview(button)
        
        let label = UILabel.init(frame: CGRectMake(frame.origin.x, y, size.width, size.height))
        label.font = UIFont.systemFontOfSize(14.0)
        label.text = text as String
        label.backgroundColor = UIColor.clearColor()
        self.view.addSubview(label)
        y += size.height + frame.size.height + spacing;
        
    }
    func addTextFieldWithPlaceholder(placeholder:NSString)->UITextField {
        let width:CGFloat = 294.0
        let x:CGFloat = round((self.view.frame.size.width - width) / 2.0)
        let textField = UITextField(frame: CGRectMake(x, y, width, 30.0))
        textField.placeholder = placeholder as String
        textField.font = UIFont.systemFontOfSize(14.0)
        textField.borderStyle = .RoundedRect
        textField.delegate = self;
        textField.keyboardType = .Default
        textField.autocorrectionType = .No
        textField.autocapitalizationType = .None
        textField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        self.view.addSubview(textField)
        
        y += 30.0 + spacing
        return textField
        
    }
    func addAppInfoLabel() {
        let text = "Library Version: \(PayPal.buildVersion())\nDemo App Version: \(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion"))"
        let font = UIFont.systemFontOfSize(14.0)
        let size: CGSize = text.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14.0)])
        let label = UILabel(frame: CGRectMake(round((self.view.frame.size.width - size.width) / 2.0), y, size.width, size.height))
        label.font = font
        label.text = text
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clearColor()
        self.view.addSubview(label)
    }
    
    
    func showAlert(alertMsg:String){
        let actionSheetController: UIAlertController = UIAlertController(title: "App", message: alertMsg, preferredStyle: .Alert)
        
        actionSheetController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { alertAction in
            actionSheetController.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
    func simplePayment(){
        preapprovalField.resignFirstResponder()
        //optional, set shippingEnabled to TRUE if you want to display shipping
        //options to the user, default: TRUE
        PayPal.getPayPalInst().shippingEnabled = false
        
        //optional, set dynamicAmountUpdateEnabled to TRUE if you want to compute
        //shipping and tax based on the user's address choice, default: FALSE
        PayPal.getPayPalInst().dynamicAmountUpdateEnabled = true
        
        //optional, choose who pays the fee, default: FEEPAYER_EACHRECEIVER
        PayPal.getPayPalInst().feePayer = FEEPAYER_EACHRECEIVER
        
        //for a payment with a single recipient, use a PayPalPayment object
        let payment = PayPalPayment()
        payment.recipient = "yourmerchant@email.com"
        payment.paymentCurrency = "USD"
        payment.description = "Teddy Bear"
        payment.merchantName = "Joe's Bear Emporium"
        
        //subtotal of all items, without tax and shipping
        payment.subTotal = NSDecimalNumber(string:"10")
        
        //invoiceData is a PayPalInvoiceData object which contains tax, shipping, and a list of PayPalInvoiceItem objects
        payment.invoiceData = PayPalInvoiceData()
        payment.invoiceData.totalShipping = NSDecimalNumber(string:"2")
        payment.invoiceData.totalTax = NSDecimalNumber(string:"0.35")
        
        //invoiceItems is a list of PayPalInvoiceItem objects
        //NOTE: sum of totalPrice for all items must equal payment.subTotal
        //NOTE: example only shows a single item, but you can have more than one
        payment.invoiceData.invoiceItems = NSMutableArray()
        let item = PayPalInvoiceItem()
        item.totalPrice = payment.subTotal
        item.name = "Teddy"
        payment.invoiceData.invoiceItems.addObject(item)
        PayPal.getPayPalInst().checkoutWithPayment(payment)
        
    }
    
    func parallelPayment(){
        preapprovalField.resignFirstResponder()
        PayPal.getPayPalInst().shippingEnabled = false
        PayPal.getPayPalInst().dynamicAmountUpdateEnabled = true
        PayPal.getPayPalInst().feePayer = FEEPAYER_EACHRECEIVER
        let payment:PayPalAdvancedPayment = PayPalAdvancedPayment()
        payment.paymentCurrency = "USD"
        payment.memo = "A Note applied to all recipients"
        payment.receiverPaymentDetails = NSMutableArray()
        let receiver1 :String = "First Receiver"
        let receiver2 :String = "Second Receiver"
        let receiver3 :String = "Third Receiver"
        let array: NSArray? = NSArray(objects: receiver1,receiver2,receiver3)
        for index in 0...2 {
            print("\(index) times 5 is \(index * 5)")
            let details:PayPalReceiverPaymentDetails = PayPalReceiverPaymentDetails()
            if index == 2 {
                details.description = "Paid for song"
            }
            details.recipient = "yourreceiver\(index + 1)@email.com"
            details.merchantName = array?.objectAtIndex(index) as! String
            let order:Int = (index + 1) * 100
            let tax:Int = (index + 1) * 7
            let shippping:Int = (index + 1) * 14
            details.subTotal = NSDecimalNumber(mantissa: UInt64(order), exponent: -2, isNegative: false)
            details.invoiceData = PayPalInvoiceData()
            details.invoiceData.totalShipping = NSDecimalNumber(mantissa: UInt64(shippping), exponent: -2, isNegative: false)
            details.invoiceData.totalTax = NSDecimalNumber(mantissa: UInt64(tax), exponent: -2, isNegative: false)
            details.invoiceData.invoiceItems = NSMutableArray()
            let item:PayPalInvoiceItem = PayPalInvoiceItem()
            item.totalPrice = details.subTotal
            item.name = "Song"
            details.invoiceData.invoiceItems.addObject(item)
            payment.receiverPaymentDetails.addObject(details)
        }
        PayPal.getPayPalInst().advancedCheckoutWithPayment(payment)
    }
    func chainedPayment(){
        
        
        //dismiss any native keyboards
        preapprovalField.resignFirstResponder()
        
        //optional, set shippingEnabled to TRUE if you want to display shipping
        //options to the user, default: TRUE
        PayPal.getPayPalInst().shippingEnabled = false
        
        //optional, set dynamicAmountUpdateEnabled to TRUE if you want to compute
        //shipping and tax based on the user's address choice, default: FALSE
        PayPal.getPayPalInst().dynamicAmountUpdateEnabled = true
        
        //optional, choose who pays the fee, default: FEEPAYER_EACHRECEIVER
        PayPal.getPayPalInst().feePayer = FEEPAYER_EACHRECEIVER
        
        //for a payment with multiple recipients, use a PayPalAdvancedPayment object
        let payment = PayPalAdvancedPayment()
        payment.paymentCurrency = "USD"
        
        //receiverPaymentDetails is a list of PPReceiverPaymentDetails objects
        payment.receiverPaymentDetails = NSMutableArray()
        
        let receiver1 :String = "First Receiver"
        let receiver2 :String = "Second Receiver"
        let receiver3 :String = "Third Receiver"
        let array: NSArray? = NSArray(objects: receiver1,receiver2,receiver3)
        for index in 0...2 {
            
            let details = PayPalReceiverPaymentDetails()
            
            details.description = "Bear Components"
            details.recipient = "yourreceiver\(index + 1)@email.com"
            details.merchantName = array?.objectAtIndex(index) as! String
            let order:Int = (index + 1) * 100
            let tax:Int = (index + 1) * 7
            let shippping:Int = (index + 1) * 14
            
            //subtotal of all items for this recipient, without tax and shipping
            details.subTotal = NSDecimalNumber(mantissa: UInt64(order), exponent: -2, isNegative: false)
            
            //invoiceData is a PayPalInvoiceData object which contains tax, shipping, and a list of PayPalInvoiceItem objects
            details.invoiceData = PayPalInvoiceData()
            details.invoiceData.totalShipping = NSDecimalNumber(mantissa: UInt64(shippping), exponent: -2, isNegative: false)
            details.invoiceData.totalTax = NSDecimalNumber(mantissa: UInt64(tax), exponent: -2, isNegative: false)
            
            
            //invoiceItems is a list of PayPalInvoiceItem objects
            //NOTE: sum of totalPrice for all items must equal details.subTotal
            //NOTE: example only shows a single item, but you can have more than one
            details.invoiceData.invoiceItems = NSMutableArray()
            let item:PayPalInvoiceItem = PayPalInvoiceItem()
            item.totalPrice = details.subTotal
            item.name = "Song"
            details.invoiceData.invoiceItems.addObject(item)
            payment.receiverPaymentDetails.addObject(details)
            
            //the only difference between setting up a chained payment and setting
            //up a parallel payment is that the chained payment must have a single
            //primary receiver.  the subTotal + totalTax + totalShipping of the
            //primary receiver must be greater than or equal to the sum of
            //payments being made to all other receivers, because the payment is
            //being made to the primary receiver, then the secondary receivers are
            //paid by the primary receiver.
            if (index == 2) {
                details.isPrimary = true
            }
            payment.receiverPaymentDetails.addObject(details)
        }
        PayPal.getPayPalInst().advancedCheckoutWithPayment(payment)
    }
    func Preapproval(){
        preapprovalField.resignFirstResponder()
        
        //the preapproval flow is kicked off by a single line of code which takes
        //the preapproval key and merchant name as parameters.
        PayPal.getPayPalInst().preapprovalWithKey(preapprovalField.text, andMerchantName: "Joe's Bear Emporium")
    }
    // # MARK: paypalDelgate methods
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
extension DPPaypalVC:PayPalPaymentDelegate {
    func retryInitialization() {
        PayPal.initializeWithAppID("APP-80W284485P519543T", forEnvironment: ENV_SANDBOX)
    }
    func paymentSuccessWithKey(payKey: String!, andStatus paymentStatus: PayPalPaymentStatus) {
        let severity = PayPal.getPayPalInst().responseMessage.objectForKey("severity")
        print("severity:\(severity)")
        let category = PayPal.getPayPalInst().responseMessage.objectForKey("category")
        print("category:\(category)")
        let errorId = PayPal.getPayPalInst().responseMessage.objectForKey("errorId")
        print("errorId:\(errorId)")
        let message = PayPal.getPayPalInst().responseMessage.objectForKey("message")
        print("message:\(message)")
        status = PaymentStatuses.PAYMENTSTATUS_SUCCESS
    }
    func paymentFailedWithCorrelationID(correlationID: String!) {
        let severity = PayPal.getPayPalInst().responseMessage.objectForKey("severity")
        print("severity:\(severity)")
        let category = PayPal.getPayPalInst().responseMessage.objectForKey("category")
        print("category:\(category)")
        let errorId = PayPal.getPayPalInst().responseMessage.objectForKey("errorId")
        print("errorId:\(errorId)")
        let message = PayPal.getPayPalInst().responseMessage.objectForKey("message")
        print("message:\(message)")
        status = PaymentStatuses.PAYMENTSTATUS_FAILED
    }
    
    func paymentLibraryExit(){
        switch status {
        case PaymentStatuses.PAYMENTSTATUS_SUCCESS:
            showAlert("Your order Success. Touch \"Pay with PayPal\"")
            break
        case PaymentStatuses.PAYMENTSTATUS_FAILED:
            showAlert("Your order failed. Touch \"Pay with PayPal\" to try again.")
            break
        case PaymentStatuses.PAYMENTSTATUS_CANCELED:
            showAlert("Your order Cancel. Touch \"Pay with PayPal\" to try again.")
            break
        }
        
    }
    func paymentCanceled() {
        status = PaymentStatuses.PAYMENTSTATUS_CANCELED;
    }
    func adjustAmountsForAddress(inAddress: PayPalAddress!, andCurrency inCurrency: String!, andAmount inAmount: NSDecimalNumber!, andTax inTax: NSDecimalNumber!, andShipping inShipping: NSDecimalNumber!) -> PayPalAmounts! {
        let newAmounts:PayPalAmounts = PayPalAmounts()
        newAmounts.currency = "USD"
        newAmounts.payment_amount = inAmount
        let numberHandler = NSDecimalNumberHandler(roundingMode: .RoundPlain, scale: 2,raiseOnExactness: true, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
        
        if inAddress.state == "CA" {
            newAmounts.tax = inAmount.decimalNumberByMultiplyingBy(0.1, withBehavior:numberHandler)
            //newAmounts.tax = NSDecimalNumber( float: inAmount .floatValue * 0.1)
        } else {
            newAmounts.tax = inAmount.decimalNumberByMultiplyingBy(0.08, withBehavior:numberHandler)
        }
        newAmounts.shipping = inShipping
        return newAmounts
        
    }
    
    func adjustAmountsAdvancedForAddress(inAddress: PayPalAddress!, andCurrency inCurrency: String!, andReceiverAmounts receiverAmounts: NSMutableArray!, andErrorCode outErrorCode: UnsafeMutablePointer<PayPalAmountErrorCode>) -> NSMutableArray! {
        let returnArray = NSMutableArray(capacity: receiverAmounts.count)
        let numberHandler = NSDecimalNumberHandler(roundingMode: .RoundPlain, scale: 2,raiseOnExactness: true, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true);
        for amount in receiverAmounts   {
            let amounts:PayPalReceiverAmounts = amount as! PayPalReceiverAmounts
            if inAddress.state == "CA" {
                //amounts.amounts.tax = NSDecimalNumber( float: amounts.amounts.payment_amount .floatValue * 0.1)
                amounts.amounts.tax =  amounts.amounts.payment_amount .decimalNumberByMultiplyingBy(0.1, withBehavior:numberHandler)
            } else {
                amounts.amounts.tax = amounts.amounts.payment_amount.decimalNumberByMultiplyingBy(0.08, withBehavior:numberHandler)
                
            }
            returnArray.addObject(amounts)
        }
        return returnArray
    }
    
    
}
