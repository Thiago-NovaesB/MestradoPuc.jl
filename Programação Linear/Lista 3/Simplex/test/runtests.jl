using Simplex
using Test
using Random
using LinearAlgebra
Random.seed!(123)

@testset "Simplex" begin

    @testset "Optimal" begin
        A = [2 1 1 0; 1 2 0 1]
        b = [4, 4]
        c = [4, 3, 0, 0]
        base = [3, 4]
        nbase = [1, 2]
        input = Simplex.create(A, b, c, base, nbase;verbose=0)
        output = Simplex.solve(input)

        @test output.x == [1.3333333333333335, 1.3333333333333333, 0.0, 0.0]
        @test output.z == 9.333333333333334
        @test output.termination_status == 1
        @test output.base == [1, 2]
        @test output.nbase == [3, 4]    
    end

    @testset "Unbound" begin
        A = [-2 1 1 0; 1 -1 0 1]
        b = [2, 2]
        c = [1, 1, 0, 0]
        base = [3, 4]
        nbase = [1, 2] 
        input = Simplex.create(A, b, c, base, nbase;verbose=0)
        output = Simplex.solve(input)

        @test output.x == [1.0, 1.0, 1.0, 0.0]
        @test output.z == Inf
        @test output.termination_status == 2
        @test output.base == [3, 1]
        @test output.nbase == [4, 2]    
    end

    @testset "10 variables" begin

        A_prime = rand(1:20,10,10)
        A = hcat(A_prime,Matrix(I,10,10))
        c = zeros(20)
        c[1:10] = rand(1:10,10)
        b = rand(1:30,10)
        nbase = collect(1:10)
        base = collect(11:20)
        input = Simplex.create(A, b, c, base, nbase;verbose=0)
        output = Simplex.solve(input)

        @test output.x == [0.021665538253215984, 0.0, 0.0775220040622884, 0.0, 0.0, 0.0, 0.0, 0.04570074475287746, 0.0, 0.0, 8.205145565335139, 6.321259309410968, 21.437711577522006, 19.794515910629656, 20.410291130670277, 0.0, 13.41198375084631, 0.0, 0.3706838185511171, 0.0]
        @test output.z == 1.052132701421801
        @test output.termination_status == 1
        @test output.base == [11, 12, 13, 14, 15, 1, 17, 3, 19, 8]
        @test output.nbase == [6, 2, 18, 4, 5, 16, 7, 20, 9, 10] 
    end

    @testset "100 variables" begin

        A_prime = rand(1:200,100,100)
        A = hcat(A_prime,Matrix(I,100,100))
        c = zeros(200)
        c[1:100] = rand(1:10,100)
        b = rand(1:30,100)
        nbase = collect(1:100)
        base = collect(101:200)
        input = Simplex.create(A, b, c, base, nbase;verbose=0)
        output = Simplex.solve(input)

        @test output.x == [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0006508539977243599, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.005957962318164744, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.004729266302564598, 0.0, 0.0, 0.0020705902255231754, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.014767380948691752, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 17.14800634837941, 8.92331004279684, 2.460376125741143, 18.007267693115693, 13.47485222316133, 9.562256560661641, 6.677147878717352, 24.46145161345749, 2.4536249978874403, 17.66959114586471, 7.161465583907538, 21.055236144848216, 5.011673790944005, 15.959878698650538, 15.00445140579506, 6.660712323122434, 7.599655315045025, 13.82787749008871, 28.36241867948468, 1.4843887172357264, 0.6784451362162832, 5.851834920970579, 4.445876248275907, 0.0, 15.651102680914546, 1.1744808888860425, 4.513688120303374, 16.387900098822332, 21.608539129951748, 10.769491444937744, 22.327046031800805, 24.08922466271495, 22.8600345182444, 15.816433092819539, 27.35050813474582, 15.257183487808419, 20.248186740981154, 11.533742702793528, 1.5572928695026294, 19.55748035427604, 0.2817460995450398, 0.5829231522128885, 19.304649577947977, 2.2034759922393627, 13.768201395960874, 2.942957215714324, 1.2527327460163484, 3.8208328760658365, 6.344240917635527, 9.128649822116564, 19.275792209643036, 23.41687771141243, 22.006371072155762, 5.550346240474677, 21.139074399098746, 19.98726664399911, 12.378002152107127, 22.045135688602873, 0.0, 2.488612144947306, 2.546744066757558, 7.341973936055161, 4.064807086706504, 26.885403505670496, 11.570106419384345, 17.72505998702788, 19.03603242015105, 21.388871891118097, 7.17075124894955, 20.40745229543541, 17.561727075334232, 5.2641348617905175, 22.497887806558282, 13.049789683689724, 0.0, 16.05522483474873, 6.389301454715951, 5.63408111235638, 15.243794903518689, 0.0, 25.005154493813603, 28.562777824748125, 27.035332759749434, 27.175050472271547, 25.631061429795707, 18.43628655592846, 4.004554447474972, 21.662714199961865, 24.7968973000776, 11.937265614814807, 20.545762094945502, 16.662693150914862, 0.0, 10.147941177223167, 14.361401099128193, 20.538643497679672, 20.0289980551438, 1.144381846583989, 9.6737490808333, 24.087673245398346]
        @test output.z == 0.2804588299312376
        @test output.termination_status == 1
        @test output.base == [101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 67, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 64, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 91, 176, 177, 178, 179, 37, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 10, 194, 195, 196, 197, 198, 199, 200]
        @test output.nbase == [1, 2, 124, 4, 5, 6, 7, 8, 9, 193, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 180, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 159, 65, 66, 73, 68, 69, 70, 71, 72, 3, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 175, 92, 93, 94, 95, 96, 97, 98, 99, 100] 
    end
end