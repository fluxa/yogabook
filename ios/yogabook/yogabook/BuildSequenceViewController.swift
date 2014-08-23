//
//  BuildSequenceViewController.swift
//  yogabook
//
//  Created by Juan-Manuel Fluxá on 7/22/14.
//  Copyright (c) 2014 fluxa.io. All rights reserved.
//

import UIKit

class BuildSequenceViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var posesCollectionView: UICollectionView!
    @IBOutlet var sequenceCollectionView: UICollectionView!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var totalTimeLabel: UILabel!
    @IBOutlet var saveButton: UIButton!
    
    var yogaSequence: YogaSequence = YogaSequence()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Double tap for adding pose to sequences
        let doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "processDoubleTap:")
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        doubleTapGesture.delaysTouchesBegan = true
        self.posesCollectionView?.addGestureRecognizer(doubleTapGesture)
        
        if !self.yogaSequence.title.isEmpty {
            self.titleTextField.text = self.yogaSequence.title
        }
        updateUI()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onDone() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSave() {
        if self.yogaSequence.poses.count > 0 {
            if !self.titleTextField.text.isEmpty {
                self.yogaSequence.title = self.titleTextField.text
                Data.sharedInstance.mySequencesDict[yogaSequence.key] = yogaSequence
                Data.sharedInstance.saveAll()
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self.titleTextField.becomeFirstResponder()
            }
            
        }
    }
    
    func processDoubleTap(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            let point: CGPoint = gesture.locationInView(self.posesCollectionView)
            if point.x >= 0 && point.y >= 0 {
                let indexPath: NSIndexPath = self.posesCollectionView.indexPathForItemAtPoint(point)
                if indexPath.row >= 0 {
                    let cell: PoseViewCell = self.posesCollectionView.cellForItemAtIndexPath(indexPath) as PoseViewCell
                    let poseInSequence = PoseInSequence(poseKey: cell.data.key)
                    self.yogaSequence.poses.append(poseInSequence)
                    reloadSequenceCollection()
                }
            }
        }
    }
    
    func reloadSequenceCollection() {
        self.sequenceCollectionView.reloadData()
        let cellW: CGFloat = 300.0
        let cellS: CGFloat = 10.0
        let w = self.view.frame.size.width
        var xOffset: CGFloat = CGFloat(self.yogaSequence.poses.count) * ( cellW + cellS ) + cellS
        xOffset = xOffset > w ? xOffset - w : 0.0
        self.sequenceCollectionView.setContentOffset(CGPointMake(xOffset, 0), animated: true)
        updateUI()
    }
    
    func updateUI() {
        updateTotalTime()
        if self.yogaSequence.poses.count > 0 {
            self.saveButton.enabled = true
        } else {
            self.saveButton.enabled = false
        }
    }
    
    func updateTotalTime() {
        let (minutes, seconds) = self.yogaSequence.getMinutesSeconds()
        self.totalTimeLabel.text = String(format: "%.2d m %.2d s", minutes, seconds)
    }
    
    // UICollectionViewDelegate
    func collectionView(_collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        
        if _collectionView == self.posesCollectionView {
            return Data.sharedInstance.poses.count
        } else if _collectionView == self.sequenceCollectionView {
            return self.yogaSequence.poses.count
        }
        
        return 0;
    }
    
    func collectionView(_collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        
        if _collectionView == self.posesCollectionView {
            
            let cell = _collectionView.dequeueReusableCellWithReuseIdentifier("PoseViewCellID", forIndexPath: indexPath) as PoseViewCell
            let pose = Data.sharedInstance.poses[indexPath.row]
            cell.data = pose
            return cell
            
        } else if _collectionView == self.sequenceCollectionView {
            
            let cell = _collectionView.dequeueReusableCellWithReuseIdentifier("PoseSequenceViewCellID", forIndexPath: indexPath) as PoseSequenceViewCell
            let poseInSequence = self.yogaSequence.poses[indexPath.row]
            cell.data = poseInSequence
            cell.onTimeChanged = {
                [weak self] in
                self!.updateTotalTime()
            }
            cell.onItemRemove = {
                [weak self, weak indexPath] in
                self!.yogaSequence.poses.removeAtIndex(indexPath!.row)
                self!.reloadSequenceCollection()
            }
            return cell
            
        }
        
        return nil
        
    }
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        
        
    }
    
    // UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField!) -> Bool {
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField!) -> Bool {
        return true
    }
}


