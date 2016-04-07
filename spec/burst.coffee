Transit  = mojs.Transit
Swirl    = mojs.Swirl
Burst    = mojs.Burst
Tunable  = mojs.Tunable
Tunable  = mojs.Tunable
t        = mojs.tweener
h        = mojs.h

describe 'Burst ->', ->
  beforeEach -> t.removeAll()

  describe 'extension ->', ->
    it 'should extend Transit class', ->
      burst = new Burst
      expect(burst instanceof Tunable).toBe true

  describe '_defaults ->', ->
    it 'should have Burst\'s defaults', ->
      burst = new Burst
      expect(burst._defaults.count).toBe 5
      expect(burst._defaults.degree).toBe 360
      expect(burst._defaults.radius).toEqual { 0 : 50 }
      expect(burst._defaults.radiusX).toEqual null
      expect(burst._defaults.radiusY).toEqual null
      expect(burst._defaults.easing).toEqual 'linear.none'
      expect(burst._defaults.isSwirl).toEqual false

  describe '_extendDefaults method ->', ->
    it 'should call _removeTweenProperties method', ->
      b = new Burst
      spyOn b, '_removeTweenProperties'
      b._extendDefaults()
      expect(b._removeTweenProperties).toHaveBeenCalledWith b._o

    it 'should call super', ->
      burst = new Burst
      spyOn mojs.Module::, '_extendDefaults'
      burst._extendDefaults()
      expect(mojs.Module::_extendDefaults).toHaveBeenCalled()

  describe '_render method ->', ->
    it 'should create master swirl', ->
      burst = new Burst
      burst.masterSwirl = undefined
      burst._render()
      expect(burst.masterSwirl instanceof Swirl).toBe true

    it 'should pass options to master swirl', ->
      opts = {}
      burst = new Burst opts
      burst.masterSwirl = undefined
      burst._render()
      expect(burst.masterSwirl._o).toBe opts

    it 'should pass isWithShape option to master swirl', ->
      opts = {}
      burst = new Burst opts
      expect(burst.masterSwirl._o.isWithShape).toBe false

    it 'should pass radius option to master swirl', ->
      opts = {}
      burst = new Burst opts
      expect(burst.masterSwirl._o.radius).toBe 0

    it 'should self as callbacksContext', ->
      opts = {}
      burst = new Burst opts
      expect(burst.masterSwirl._o.callbacksContext).toBe burst

    it 'should call _saveTimelineOptions method', ->
      opts = {}
      b = new Burst opts
      spyOn b, '_saveTimelineOptions'
      b._render()
      expect(b._saveTimelineOptions).toHaveBeenCalledWith b._o

    it 'should call _renderSwirls method', ->
      opts = {}
      burst = new Burst opts
      spyOn burst, '_renderSwirls'
      burst._render()
      expect(burst._renderSwirls).toHaveBeenCalled()

    it 'should create _masterSwirls object', ->
      burst = new Burst
      expect(burst._masterSwirls[0]).toBe burst.masterSwirl
      expect(typeof burst._masterSwirls).toBe 'object'
      # not null
      expect(burst._masterSwirls).toBe burst._masterSwirls

    it 'should add optional properties to option', ->
      burst = new Burst
      spyOn burst, '_addOptionalProps'
      burst._renderSwirls()
      
      expect(burst._addOptionalProps.calls.count()).toBe 5

    it 'should set time on tween of masterSwirl', ->
      burst = new Burst
        # isIt: 1
        childOptions:
          duration: 'stagger(500, 1000)'
          repeat: 2
      burst.masterSwirl.tween._props.duration = null
      burst._renderSwirls()
      # console.log burst.masterSwirl.tween._props.duration
      expect(burst.masterSwirl.tween._props.duration)
        .toBe burst._calcPackTime burst._swirls[0]

    it 'should set isSwirl to false by default', ->
      burst = new Burst
        childOptions:
          duration: 'stagger(500, 1000)'
          repeat: 2

      expect(burst.masterSwirl._props.isSwirl).toBe false

    it 'should work with isSwirl option', ->
      burst = new Burst
        isSwirl: true
        childOptions:
          duration: 'stagger(500, 1000)'
          repeat: 2

      expect(burst.masterSwirl._props.isSwirl).toBe true

  describe '_renderSwirls method', ->
    it 'should create _swirls object', ->
      burst = new Burst
      expect(typeof burst._swirls).toBe 'object'
      # not null
      expect(burst._swirls).toBe burst._swirls

    it 'should create _swirls pack', ->
      count = 5
      burst = new Burst count: count
      pack = burst._swirls[0]
      expect( h.isArray(pack) ).toBe true
      expect( pack.length ).toBe count
      expect( pack[0] instanceof Swirl ).toBe true
      expect( pack[1] instanceof Swirl ).toBe true
      expect( pack[2] instanceof Swirl ).toBe true
      expect( pack[3] instanceof Swirl ).toBe true
      expect( pack[4] instanceof Swirl ).toBe true

    it 'should pass options to swirls', ->
      count = 5; fills = [ 'cyan', 'yellow', 'blue' ]
      burst = new Burst
        count: count
        childOptions:
          fill: fills
      pack = burst._swirls[0]
      expect( pack[0]._o.fill ).toBe fills[0]
      expect( pack[1]._o.fill ).toBe fills[1]
      expect( pack[2]._o.fill ).toBe fills[2]
      expect( pack[3]._o.fill ).toBe fills[0]
      expect( pack[4]._o.fill ).toBe fills[1]

    it 'should parent to swirls', ->
      count = 5
      burst = new Burst
        count: count
        # childOptions: {}

      pack = burst._swirls[0]
      expect( pack[0]._o.parent ).toBe burst.masterSwirl.el
      expect( pack[1]._o.parent ).toBe burst.masterSwirl.el
      expect( pack[2]._o.parent ).toBe burst.masterSwirl.el
      expect( pack[3]._o.parent ).toBe burst.masterSwirl.el
      expect( pack[4]._o.parent ).toBe burst.masterSwirl.el

  describe '_getChildOption method ->', ->
    it 'should get options from childOptions', ->
      b = new Burst count: 2
      o = { childOptions: { fill: [ 'yellow', 'cyan', 'blue' ] } }
      result = b._getChildOption( o, 1 )
      expect(result.fill).toBe 'cyan'

      it 'should not throw if there is no childOptions', ->
        b = new Burst count: 2
        o = { }
        result = b._getChildOption( o, 1 )
        expect(result).toEqual {}

  describe '_getPropByMod method ->', ->
    it 'should fallback to empty object', ->
      burst = new Burst
        childOptions: radius: [ { 20: 50}, 20, '500' ]
      opt0 = burst._getPropByMod 'radius', 0
      expect(opt0).toBe undefined
    it 'should return the prop from passed object based on index ->', ->
      burst = new Burst
        childOptions: radius: [ { 20: 50}, 20, '500' ]
      opt0 = burst._getPropByMod 'radius', 0, burst._o.childOptions
      opt1 = burst._getPropByMod 'radius', 1, burst._o.childOptions
      opt2 = burst._getPropByMod 'radius', 2, burst._o.childOptions
      opt8 = burst._getPropByMod 'radius', 8, burst._o.childOptions
      expect(opt0[20]).toBe 50
      expect(opt1)    .toBe 20
      expect(opt2)    .toBe '500'
      expect(opt8)    .toBe '500'
    it 'should the same prop if not an array ->', ->
      burst = new Burst childOptions: radius: 20
      opt0 = burst._getPropByMod 'radius', 0, burst._o.childOptions
      opt1 = burst._getPropByMod 'radius', 1, burst._o.childOptions
      opt8 = burst._getPropByMod 'radius', 8, burst._o.childOptions
      expect(opt0).toBe 20
      expect(opt1).toBe 20
      expect(opt8).toBe 20
    it 'should work with another options object ->', ->
      burst = new Burst
        fill: 'cyan'
        childOptions: radius: 20

      from = burst._o
      opt0 = burst._getPropByMod 'fill', 0, from
      opt1 = burst._getPropByMod 'fill', 1, from
      opt8 = burst._getPropByMod 'fill', 8, from

      expect(opt0).toBe 'cyan'
      expect(opt1).toBe 'cyan'
      expect(opt8).toBe 'cyan'

  describe '_makeTween method ->', ->
    it 'should override parent', ->
      bs = new Burst
      spyOn mojs.Tweenable.prototype, '_makeTween'
      bs._makeTween()
      expect(mojs.Tweenable.prototype._makeTween).not.toHaveBeenCalled()

  describe '_makeTimeline method ->', ->

    it 'should restore timeline options on _o', ->
      timeline = {}
      bs = new Burst timeline: timeline
      bs._makeTimeline()
      expect(bs._o.timeline).toBe timeline

    it 'should call super', ->
      bs = new Burst
      spyOn mojs.Tweenable::, '_makeTimeline'
      bs._makeTimeline()
      expect(mojs.Tweenable::_makeTimeline).toHaveBeenCalled()

    it 'should add masterSwirl to the timeline', ->
      bs = new Burst
      expect(bs.timeline._timelines[0]).toBe bs.masterSwirl.timeline

    it 'should add swirls to the timeline', ->
      bs = new Burst count: 5
      expect(bs.timeline._timelines[1]).toBe bs._swirls[0][0].timeline
      expect(bs.timeline._timelines[2]).toBe bs._swirls[0][1].timeline
      expect(bs.timeline._timelines[3]).toBe bs._swirls[0][2].timeline
      expect(bs.timeline._timelines[4]).toBe bs._swirls[0][3].timeline
      expect(bs.timeline._timelines[5]).toBe bs._swirls[0][4].timeline

  describe '_addOptionalProps method ->', ->
    it 'should return the passed object', ->
      burst = new Burst
      obj = {}
      result = burst._addOptionalProps obj, 0
      expect(result).toBe obj

    it 'should add parent, index', ->
      burst = new Burst
      obj = {}
      result = burst._addOptionalProps obj, 0
      expect(result.index).toBe 0
      expect(result.parent).toBe burst.masterSwirl.el

    it 'should set isSiwrl to false by default', ->
      burst = new Burst
      obj = { }
      result = burst._addOptionalProps obj, 0
      expect(result.isSwirl).toBe false

      obj = { isSwirl: true }
      result = burst._addOptionalProps obj, 0
      expect(result.isSwirl).toBe true

    it 'should hard rewrite `left` and `top` properties to 50%', ->
      burst = new Burst
      obj = {}
      result = burst._addOptionalProps obj, 0
      expect(result.left).toBe '50%'
      expect(result.top).toBe '50%'

    it 'should add x/y ->', ->
      burst = new Burst
        radius: { 0: 100 }
        count:  2,
        size: 0,

      obj0 = {}
      obj1 = {}
      result0 = burst._addOptionalProps obj0, 0
      result1 = burst._addOptionalProps obj1, 1

      expect(obj0.x[0]).toBeCloseTo 0, 5
      expect(obj0.y[0]).toBeCloseTo -100, 5

      expect(obj1.x[0]).toBeCloseTo 0, 5
      expect(obj1.y[0]).toBeCloseTo 100, 5

    it 'should add angles ->', ->
      burst = new Burst
        radius: { 0: 100 }
        count:  2

      obj0 = { angle: 0 }
      obj1 = { angle: 0 }
      result0 = burst._addOptionalProps obj0, 0
      result1 = burst._addOptionalProps obj1, 1

      expect(obj0.angle).toBe 90
      expect(obj1.angle).toBe 270

  describe '_getBitAngle method ->', ->
    it 'should get angle by i', ->
      burst = new Burst radius: { 'rand(10,20)': 100 }
      expect(burst._getBitAngle(0, 0)).toBe 90
      expect(burst._getBitAngle(0, 1)).toBe 162
      expect(burst._getBitAngle(0, 2)).toBe 234
      expect(burst._getBitAngle(90, 2)).toBe 234 + 90
      expect(burst._getBitAngle(0, 3)).toBe 306
      expect(burst._getBitAngle(90, 3)).toBe 306 + 90
      expect(burst._getBitAngle(0, 4)).toBe 378
      expect(burst._getBitAngle(50, 4)).toBe 378 + 50
    it 'should fallback to 0', ->
      burst = new Burst radius: { 'rand(10,20)': 100 }
      expect(burst._getBitAngle(undefined, 0)).toBe 90
      expect(burst._getBitAngle(undefined, 1)).toBe 162
      expect(burst._getBitAngle(undefined, 2)).toBe 234
    it 'should get delta angle by i', ->
      burst = new Burst radius: { 'rand(10,20)': 100 }
      expect(burst._getBitAngle({180:0}, 0)[270]).toBe 90
      expect(burst._getBitAngle({50:20}, 3)[356]).toBe 326
      expect(burst._getBitAngle({50:20}, 4)[428]).toBe 398

    it 'should work with `stagger` values', ->
      burst = new Burst count: 2
      
      expect(burst._getBitAngle({'stagger(20, 10)':0}, 0)[110]).toBe 90
      expect(burst._getBitAngle({'stagger(20, 10)':0}, 1)[300]).toBe 270

      expect(burst._getBitAngle({0:'stagger(20, 10)'}, 1)[270]).toBe 300

    it 'should work with `random` values', ->
      burst = new Burst count: 2
      
      angle = burst._getBitAngle({'rand(10, 20)':0}, 0)
      for key, value in angle
        baseAngle = 90
        expect(parseInt(key)).toBeGreaterThan  baseAngle + 10
        expect(parseInt(key)).not.toBeGreaterThan baseAngle + 20
        expect(parseInt(value)).toBe baseAngle

      angle = burst._getBitAngle({'rand(10, 20)':0}, 1)
      for key, value in angle
        baseAngle = 270
        expect(parseInt(key)).toBeGreaterThan  baseAngle + 10
        expect(parseInt(key)).not.toBeGreaterThan baseAngle + 20
        expect(parseInt(value)).toBe baseAngle

      angle = burst._getBitAngle({0:'rand(10, 20)'}, 1)
      for key, value in angle
        baseAngle = 270
        expect(parseInt(key)).toBe baseAngle
        expect(parseInt(value)).toBeGreaterThan  baseAngle + 10
        expect(parseInt(value)).not.toBeGreaterThan baseAngle + 20

  describe '_getSidePoint method ->', ->
    it 'should return the side\'s point', ->
      burst = new Burst radius: {5:25}, radiusX: {10:20}, radiusY: {30:10}
      point = burst._getSidePoint('start', 0)
      expect(point.x).toBeDefined()
      expect(point.y).toBeDefined()

  describe '_getSideRadius method ->', ->
    it 'should return the side\'s radius, radiusX and radiusY', ->
      burst = new Burst radius: {5:25}, radiusX: {10:20}, radiusY: {30:10}
      sides = burst._getSideRadius('start')
      expect(sides.radius) .toBe 5
      expect(sides.radiusX).toBe 10
      expect(sides.radiusY).toBe 30

  describe '_getRadiusByKey method ->', ->
    it 'should return the key\'s radius', ->
      burst = new Burst radius: {5:25}, radiusX: {10:20}, radiusY: {30:20}
      radius  = burst._getRadiusByKey('radius',  'start')
      radiusX = burst._getRadiusByKey('radiusX', 'start')
      radiusY = burst._getRadiusByKey('radiusX', 'end')
      expect(radius).toBe   5
      expect(radiusX).toBe 10
      expect(radiusY).toBe 20

  describe '_getDeltaFromPoints method ->', ->
    it 'should return the delta', ->
      burst = new Burst
      delta  = burst._getDeltaFromPoints('x', {x: 10, y: 20}, {x: 20, y: 40})
      expect(delta[10]).toBe 20
    it 'should return one value if start and end positions are equal', ->
      burst = new Burst
      delta  = burst._getDeltaFromPoints('x', {x: 10, y: 20}, {x: 10, y: 40})
      expect(delta).toBe 10

  describe '_vars method ->', ->
    it 'should call super', ->
      burst = new Burst
      spyOn mojs.Thenable::, '_vars'
      burst._vars()
      expect(mojs.Thenable::_vars).toHaveBeenCalled()
    it 'should create _bufferTimeline', ->
      burst = new Burst
      burst._bufferTimeline = null
      burst._vars()
      expect(burst._bufferTimeline instanceof mojs.Timeline).toBe true

  describe '_recalcModulesTime method', ->
    it 'should set duration on every moddules tween', ->
      b = new Burst(fill: 'cyan').then('fill': 'yellow')
      shiftTime = 0
      modules = b.masterSwirl._modules

      spyOn(b, '_calcPackTime').and.callThrough()
      b._recalcModulesTime()
      
      expect(b._calcPackTime).toHaveBeenCalledWith b._swirls[0]
      time = b._calcPackTime(b._swirls[0])
      expect(modules[0].tween._props.duration).toBe  time
      expect(modules[0].tween._props.shiftTime).toBe shiftTime

      shiftTime += time

      expect(b._calcPackTime).toHaveBeenCalledWith b._swirls[1]
      time = b._calcPackTime(b._swirls[1])
      expect(modules[1].tween._props.duration).toBe  time
      expect(modules[1].tween._props.shiftTime).toBe shiftTime

      shiftTime += time

    it 'should call _recalcTotalDuration on main timeline', ->
      b = new Burst(fill: 'cyan').then('fill': 'yellow')
      spyOn b.timeline, '_recalcTotalDuration'

      b._recalcModulesTime()

      expect(b.timeline._recalcTotalDuration).toHaveBeenCalled()


  describe '_masterThen method ->', ->
    it 'should pass options to masterSwirl', ->
      b = new Burst count: 2
        
      spyOn b.masterSwirl, 'then'

      o = { opacity: .5 }
      b._masterThen(o)

      expect( b.masterSwirl.then ).toHaveBeenCalledWith o

    it 'should save the new master swirl', ->
      b = new Burst count: 2
        
      b._masterThen( { opacity: .5 } )
      expect( b._masterSwirls.length ).toBe 2

    it 'should return the new swirl', ->
      b = new Burst count: 2
        
      result = b._masterThen( { opacity: .5 } )
      expect( result ).toBe b._masterSwirls[b._masterSwirls.length-1]

  describe '_childThen method ->', ->
    it 'should pass options to swirls', ->
      b = new Burst count: 2
        
      pack = b._swirls[0] 
      spyOn pack[0], 'then'
      spyOn pack[1], 'then'

      o = { childOptions: { radius: [ 10, 20 ] } }
      b._childThen(o, b._masterThen(o))

      option0 = b._getChildOption( o, 0 )
      option0.parent = b._masterSwirls[1].el
      expect(pack[0].then).toHaveBeenCalledWith option0

      option1 = b._getChildOption( o, 1 )
      option1.parent = b._masterSwirls[1].el
      expect(pack[1].then).toHaveBeenCalledWith option1

    it 'should save new swirls to _swirls', ->
      b = new Burst count: 2
        
      o = { childOptions: { radius: [ 10, 20 ] } }

      b._childThen(o, b._masterThen(o))

      expect(b._swirls[1].length).toBe 2
      expect(b._swirls[1][0] instanceof Swirl).toBe true
      expect(b._swirls[1][1] instanceof Swirl).toBe true

    it 'should return the new pack', ->
      b = new Burst count: 2
        
      o = { childOptions: { radius: [ 10, 20 ] } }

      result = b._childThen(o, b._masterThen(o))

      expect(result).toBe b._swirls[1]

  describe 'then method ->', ->
    it 'should return this', ->
      b = new Burst count: 2
      expect( b.then({}) ).toBe b

    it 'should call _removeTweenProperties method', ->
      b = new Burst
      spyOn b, '_removeTweenProperties'
      options = { x: 200 }
      b.then(options)
      expect(b._removeTweenProperties).toHaveBeenCalledWith options

    it 'should call _masterThen method', ->
      b = new Burst count: 2
      spyOn(b, '_masterThen').and.callThrough()
      options = {}
      b.then options
      expect( b._masterThen ).toHaveBeenCalledWith options

    it 'should call _childThen method', ->
      b = new Burst count: 2
      spyOn(b, '_childThen').and.callThrough()
      options = {}
      b.then options

      # expect( b._childThen )
      #   .toHaveBeenCalledWith options, h.getLastItem b._masterSwirls

      expect(b._childThen.calls.count()).toBe 1
      expect(b._childThen.calls.first().args[0]).toBe options
      expect(b._childThen.calls.first().args[1])
        .toBe h.getLastItem b._masterSwirls

    it 'should set duration on new master swirl', ->
      b = new Burst count: 2
      spyOn(b, '_setSwirlDuration').and.callThrough()
      b.then({ childOptions: { duration: 50 } })
      time = b._calcPackTime( b._swirls[1] )

      expect(b._setSwirlDuration.calls.count()).toBe 1
      expect(b._setSwirlDuration.calls.first().args[0])
        .toBe b._masterSwirls[1]
      expect(b._setSwirlDuration.calls.first().args[1])
        .toBe time

    it 'should call _recalcTotalDuration method', ->
      b = new Burst count: 2
  
      spyOn b.timeline, '_recalcTotalDuration'      
      b.then({ childOptions: { radius: [ 10, 20 ] } })

      expect(b.timeline._recalcTotalDuration).toHaveBeenCalled()

  describe '_calcPackTime method ->', ->
    it 'should calculate time of swirls array', ->
      # should not include shift time
      sw = new Swirl
      sw.timeline._props.shiftTime = 200000

      pack = [
        sw,
        new Swirl( duration: 2000 ),
        new Swirl( duration: 1800, delay: 400 ),
        new Swirl( duration: 4000, speed: 3 )
      ]

      b = new Burst
      tm = new mojs.Timeline

      maxTime = 0
      for swirl, i in pack
        tween = swirl.tween; p = tween._props
        maxTime = Math.max( p.repeatTime/p.speed, maxTime )

      expect( b._calcPackTime pack ).toBe maxTime

  describe '_setSwirlDuration method ->', ->
    it 'should set tweens time', ->
      b = new Burst
      sw = new Swirl

      spyOn sw.tween,    '_setProp'
      spyOn sw.timeline, '_recalcTotalDuration'

      duration = 10
      b._setSwirlDuration sw, duration

      expect(sw.tween._setProp).toHaveBeenCalledWith 'duration', duration
      expect(sw.timeline._recalcTotalDuration).toHaveBeenCalled()

    it 'should not throw if Swirl has no timeline', ->
      b = new Burst
      sw = new Swirl

      sw.timeline = sw.tween

      set = -> b._setSwirlDuration sw, 10

      expect(set).not.toThrow()

  describe 'tune method ->', ->
    it 'should return `this`', ->
      b = new Burst
      expect(b.tune({ x: 200 })).toBe b

    it 'should call _tuneNewOptions method', ->
      b = new Burst
      spyOn b, '_tuneNewOptions'
      options = { x: 200 }
      b.tune(options)
      expect(b._tuneNewOptions).toHaveBeenCalledWith options

    it 'should not call _tuneNewOptions method if no options', ->
      b = new Burst
      spyOn b, '_tuneNewOptions'
      options = null
      result = b.tune(options)
      expect(b._tuneNewOptions).not.toHaveBeenCalledWith options
      # should return `this` in this case
      expect(result).toBe b

    it 'should call tune on masterSwirl', ->
      b = new Burst
      spyOn b.masterSwirl, 'tune'
      options = { x: 200 }
      b.tune(options)
      expect(b.masterSwirl.tune).toHaveBeenCalledWith options

    it 'should call _tuneSwirls method', ->
      b = new Burst
      spyOn b, '_tuneSwirls'
      options = { x: 200 }
      b.tune(options)
      expect(b._tuneSwirls).toHaveBeenCalledWith options

    it 'should call tune 0 pack swirls', ->
      b = new Burst

      pack0 = b._swirls[0]
      spyOn pack0[0], 'tune'
      spyOn pack0[1], 'tune'
      spyOn pack0[2], 'tune'
      spyOn pack0[3], 'tune'
      spyOn pack0[4], 'tune'

      childOptions = { x: 200, fill: ['cyan', 'yellow'] }
      options = { childOptions: childOptions }
      b.tune( options )

      option0 = b._getChildOption options, 0
      b._addBurstProperties option0, 0
      args = pack0[0].tune.calls.first().args
      expect(args[0]).toEqual option0

      option1 = b._getChildOption options, 1
      b._addBurstProperties option1, 1
      args = pack0[1].tune.calls.first().args
      expect(args[0]).toEqual option1

      option2 = b._getChildOption options, 2
      b._addBurstProperties option2, 2
      args = pack0[2].tune.calls.first().args
      expect(args[0]).toEqual option2

      option3 = b._getChildOption options, 3
      b._addBurstProperties option3, 3
      args = pack0[3].tune.calls.first().args
      expect(args[0]).toEqual option3

      option4 = b._getChildOption options, 4
      b._addBurstProperties option4, 4
      args = pack0[4].tune.calls.first().args
      expect(args[0]).toEqual option4

    it 'should add Burst properties to options', ->
      b = new Burst
      spyOn b.masterSwirl, 'tune'
      options = { x: 200 }
      spyOn b, '_addBurstProperties'
      b.tune(options)
      expect(b._addBurstProperties).toHaveBeenCalledWith {}, 0
      expect(b._addBurstProperties).toHaveBeenCalledWith {}, 1
      expect(b._addBurstProperties).toHaveBeenCalledWith {}, 2
      expect(b._addBurstProperties).toHaveBeenCalledWith {}, 3
      expect(b._addBurstProperties).toHaveBeenCalledWith {}, 4

    it 'should call _recalcModulesTime method', ->
      b = new Burst
      spyOn b, '_recalcModulesTime'
      options = { x: 200 }
      b.tune(options)
      expect(b._recalcModulesTime).toHaveBeenCalled()

    it 'should call _saveTimelineOptions method', ->
      b = new Burst
      spyOn b, '_saveTimelineOptions'
      options = { x: 200 }
      b.tune(options)
      expect(b._saveTimelineOptions).toHaveBeenCalledWith options

    it 'should set new options on timeline', ->
      b = new Burst
      spyOn b.timeline, '_setProp'
      options = { x: 200 }
      b.tune(options)
      expect(b.timeline._setProp).toHaveBeenCalledWith b._timelineOptions

  describe '_removeTweenProperties method ->', ->
    it 'should remove all tween props from passed object', ->
      b = new Burst
      o = {}
      for key of h.tweenOptionMap
        o[key] = 1

      for key of b._defaults
        o[key] = 1

      b._removeTweenProperties(o)

      for key of h.tweenOptionMap
        if key isnt 'easing'
          expect(o[key]).not.toBeDefined()
      
      expect(o['easing']).toBe 1

      for key of b._defaults
        expect(o[key]).toBe 1

  describe '_saveTimelineOptions method ->', ->
    it 'should save timeline options to _timelineOptions', ->
      b = new Burst
      timeline = {}
      opts = { timeline: timeline }
      b._saveTimelineOptions opts
      expect( b._timelineOptions ).toBe timeline
      expect( opts.timeline ).not.toBeDefined()

    # nope
    # it 'should set _timelineOptions to null first', ->
    #   b = new Burst
    #   opts = { }
    #   b._saveTimelineOptions opts
    #   expect( b._timelineOptions ).toBe null



